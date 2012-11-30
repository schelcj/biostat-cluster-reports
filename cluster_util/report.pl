#!/usr/bin/perl

## no critic (ValuesAndExpressions::ProhibitMagicNumbers, ValuesAndExpressions::ProhibitMismatchedOperators)

use Modern::Perl;
use Class::Date;
use System::Command;
use File::Slurp qw(write_file);
use Class::CSV;

my $now         = Class::Date->now();
my $report_cmd  = q{sreport -P -n cluster util start=%s end=%s};
my @headers     = (qw(cluster allocated down plnd_down idle reserved reported));
my $util_ref    = {};
my $yaxis_scale = 1_000_000;
my $r_data_file = q{cluster_util.dat};
my $r_dat       = Class::CSV->new(fields => ['date', @headers]);

for (1 .. 12) {
  my $start       = $now->month_begin->strftime('%Y-%m-%d');
  my $end         = $now->month_end->strftime('%Y-%m-%d');
  my $command     = sprintf $report_cmd, $start, $end;
  my $results_ref = get_util($command);

  $util_ref->{$start} = $results_ref;

  $now -= '1M';
}

$r_dat->add_line({map {$_ => $_} ('date', @headers)});

foreach my $date (sort keys %{$util_ref}) {
  my $result_ref   = $util_ref->{$date};
  (my $xaxis_label = $date) =~ s/\d{2}(\d{2})\-(\d{2})\-\d{2}/$1\/$2/g;

  my $row = {date => $date, map {$_ => (exists $result_ref->{$_}) ? $result_ref->{$_} : 0} @headers};

  $r_dat->add_line($row);
}

write_file($r_data_file, $r_dat->string());

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
