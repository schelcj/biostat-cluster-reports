#!/usr/bin/perl

use Modern::Perl;
use Class::Date;
use GD::Chart;
use System::Command;
use File::Slurp qw(append_file);
use Data::Dumper;

my $now         = Class::Date->now();
my $date        = Class::Date->new([$now->year, qw(01 01 00 00 00)]);
my $report_cmd  = q{sreport -P -n cluster util start=%s end=%s};
my @headers     = (qw(cluster allocated down plnd_down idle reserved reported));
my %files       = map {$_ => qq{data/${_}.data}} @headers;
my $util_ref    = {};
my $yaxis_scale = 1000000;

for (1 .. $now->month) {
  my $start       = $date->month_begin->strftime('%Y-%m-%d');
  my $end         = $date->month_end->strftime('%Y-%m-%d');
  my $command     = sprintf $report_cmd, $start, $end;
  my $results_ref = get_util($command);

  $util_ref->{$start} = $results_ref;

  $date += '1M';    ## no critic (ValuesAndExpressions::ProhibitMismatchedOperators)
}

foreach my $date (sort keys %{$util_ref}) {
  (my $xaxis_label = $date) =~ s/\d{4}\-(\d{2})\-\d{2}/$1/g;
  map {
    my $data_point = $util_ref->{$date}->{$_} / $yaxis_scale;
    append_file($files{$_}, qq#$xaxis_label $data_point\n#)
  } keys %{$util_ref->{$date}};
}

sub get_util {
  my ($command) = @_;

  my %item   = ();
  my $cmd    = System::Command->new($command);
  my $stdout = $cmd->stdout();

  while (<$stdout>) {
    chomp;
    @item{@headers} = split(/[|]/);
  }

  $cmd->close();

  delete $item{cluster};

  return \%item;
}
