#!/usr/bin/env perl

use Modern::Perl;
use IPC::System::Simple qw(capture);
use Readonly;
use Class::Date;
use Class::CSV;
use File::Slurp qw(write_file);

Readonly::Scalar my $WEEK        => q{7D};
Readonly::Scalar my $DATE_FORMAT => q{%Y-%m-%d};
Readonly::Scalar my $CMD         => q{sacct -a -n -X -P -S %s -E %s};
Readonly::Scalar my $FILE        => q{report.dat};
Readonly::Array my @HEADERS      => (qw(date total_jobs));

my $csv    = Class::CSV->new(fields => \@HEADERS);
my $now    = Class::Date->now();
my $start  = $now - $WEEK;
my $end    = $now;
my %params = ();

$csv->add_line({map {$_ => $_} @HEADERS});

for (1 .. 52) {
  my $total_jobs = get_total_jobs_for_week($start->strftime($DATE_FORMAT), $end->strftime($DATE_FORMAT));

  $params{$start->strftime($DATE_FORMAT)} = $total_jobs;

  $start = $start - $WEEK;
  $end   = $end - $WEEK;
}

map {$csv->add_line({date => $_, total_jobs => $params{$_}})} sort {$a cmp $b} keys %params;

write_file($FILE, $csv->string());

sub get_total_jobs_for_week {
  my ($start_date, $end_date) = @_;
  my $cmd = sprintf $CMD, $start_date, $end_date;
  my @results = capture($cmd);
  return scalar @results;
}
