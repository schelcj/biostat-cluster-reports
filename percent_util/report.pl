#!/usr/bin/perl

## no critic (ValuesAndExpressions::ProhibitMagicNumbers, ValuesAndExpressions::ProhibitMismatchedOperators)

use Modern::Perl;
use Class::Date;
use System::Command;
use File::Slurp qw(append_file);

my $report_cmd  = q{sreport -P -n cluster util start=%s end=%s};
my @headers     = (qw(cluster allocated down plnd_down idle reserved reported));
my $yaxis_scale = 1_000_000;
my $date_format = q{%Y-%m-%d};

my $now        = Class::Date->now();
my $start_date = $now - '12M';
my $start      = $start_date->month_begin->strftime($date_format);
my $end        = $now->month_end->strftime($date_format);
my $command    = sprintf $report_cmd, $start, $end;

my %item   = ();
my $cmd    = System::Command->new($command);
my $stdout = $cmd->stdout();

while (<$stdout>) {
  chomp;
  @item{@headers} = split(/[|]/);
}

$cmd->close();

say "Total Cluster Utilization for ($start - $end)";
say '-------------------------------------------------------';
foreach my $header (@headers) {
  next if $header eq 'cluster';
  printf "%-45s %.2f%%\n", ucfirst($header), (($item{$header} / $item{reported}) * 100);
}
