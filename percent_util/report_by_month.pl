#!/usr/bin/perl

## no critic (ValuesAndExpressions::ProhibitMagicNumbers, ValuesAndExpressions::ProhibitMismatchedOperators)

use Modern::Perl;
use Class::Date;
use System::Command;
use Excel::Template;
use Data::Dumper;

my $template    = q{template_by_month.xml};
my $report      = q{percent_util_by_month.xls};
my $report_cmd  = q{sreport -P -n cluster util start=%s end=%s};
my @headers     = (qw(cluster allocated down plnd_down idle reserved reported));
my $yaxis_scale = 1_000_000;
my $date_format = q{%Y-%m-%d};
my $date        = Class::Date->now();
my $excel       = Excel::Template->new(filename => $template);
my $params      = {};

for (1 .. 12) {
  $date -= '1M';

  my $start   = $date->month_begin->strftime($date_format);
  my $end     = $date->month_end->strftime($date_format);
  my $command = sprintf $report_cmd, $start, $end;

  my $result_ref = {};
  my %item       = ();
  my $cmd        = System::Command->new($command);
  my $stdout     = $cmd->stdout();

  while (<$stdout>) {
    chomp;
    @item{@headers} = split(/[|]/);
  }

  $cmd->close();

  $params->{caption}    = "Utilization percent by month";
  $result_ref->{period} = $date->strftime(q{%Y/%m});
  $result_ref->{cmd}    = $command;

  foreach my $header (@headers) {
    next if $header eq 'cluster';

    my $percent = ($item{reported}) ? sprintf '%.2f', (($item{$header} / $item{reported}) * 100) : 0;

    $result_ref->{$header} = $percent;
  }

  push @{$params->{results}}, $result_ref;
}

$excel->param($params);
$excel->write_file($report);
