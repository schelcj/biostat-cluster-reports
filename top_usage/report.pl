#!/usr/bin/perl

use Modern::Perl;
use FindBin qw($Bin);
use Class::Date;
use System::Command;
use Excel::Template;
use Data::Dumper;
use Class::CSV;
use File::Slurp qw(write_file);

my $now         = Class::Date->now();
my $start_date  = $now - '1Y';
my $template    = qq{$Bin/./template.xml};
my $report      = qq{$Bin/./top_usage.xls};
my $report_cmd  = q{sreport -P -n cluster userutilizationbyaccount start=%s end=%s};
my $date_format = q{%Y-%m-%d};
my @headers     = (qw(cluster login name account cpu_min));
my $command     = sprintf $report_cmd, $start_date->strftime($date_format), $now->strftime($date_format);
my $params      = {results => []};
my $excel       = Excel::Template->new(filename => $template);
my $csv         = Class::CSV->new(fields => \@headers);
my $r_data      = q{report.dat};

@{$params->{results}} = sort {$b->{cpu_min} <=> $a->{cpu_min}} get_usage($command);

$csv->add_line({map {$_ => $_} @headers});
for my $result (@{$params->{results}}) {
  my $line = {map {$_ => $result->{$_}} @headers};
  $csv->add_line($line);
}
write_file($r_data, $csv->string());

$excel->param($params);
$excel->write_file($report);

sub get_usage {
  my ($command) = @_;
  my @results   = ();
  my $cmd       = System::Command->new($command);
  my $stdout    = $cmd->stdout();

  while (<$stdout>) {
    chomp;
    my %result = ();
    @result{@headers} = split(/[|]/);
    next if $result{account} =~ /biostat|root/;
    push @results, \%result;
  }

  $cmd->close();

  return @results;
}
