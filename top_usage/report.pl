#!/usr/bin/perl

use Modern::Perl;
use FindBin qw($Bin);
use Class::Date;
use System::Command;
use Excel::Template;
use Data::Dumper;

my $now         = Class::Date->now();
my $start_date  = $now - '3M';
my $template    = qq{$Bin/./template.xml};
my $report      = qq{$Bin/./top_usage.xls};
my $report_cmd  = q{sreport -P -n user top start=%s end=%s};
my $date_format = q{%Y-%m-%d};
my @headers     = (qw(cluster login name account cpu_min));
my $command     = sprintf $report_cmd, $start_date->strftime($date_format), $now->strftime($date_format);
my $params      = { results => [] };
my $excel       = Excel::Template->new(filename => $template);

@{$params->{results}} = sort { $b->{cpu_min} <=> $a->{cpu_min} } get_usage($command);
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
