#!/usr/bin/perl

## no critic (ValuesAndExpressions::ProhibitMagicNumbers, ValuesAndExpressions::ProhibitMismatchedOperators)

use Modern::Perl;
use Class::Date;
use System::Command;
use File::Slurp qw(append_file);

my $now         = Class::Date->now();
my $report_cmd  = q{sreport -P -n cluster util start=%s end=%s};
my @headers     = (qw(cluster allocated down plnd_down idle reserved reported));
my %files       = map {$_ => qq{${_}.data}} @headers;
my $util_ref    = {};
my $yaxis_scale = 1_000_000;

for (1 .. 12) {
  my $start       = $now->month_begin->strftime('%Y-%m-%d');
  my $end         = $now->month_end->strftime('%Y-%m-%d');
  my $command     = sprintf $report_cmd, $start, $end;
  my $results_ref = get_util($command);

  $util_ref->{$start} = $results_ref;

  $now -= '1M';
}

foreach my $date (sort keys %{$util_ref}) {
  (my $xaxis_label = $date) =~ s/\d{2}(\d{2})\-(\d{2})\-\d{2}/$1\/$2/g;

  foreach my $dpoint (keys %{$util_ref->{$date}}) {
    my $data_point = $util_ref->{$date}->{$dpoint} / $yaxis_scale;

    append_file($files{$dpoint}, qq#$xaxis_label $data_point\n#)
  }
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
