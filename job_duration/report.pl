#!/usr/bin/env perl

use Modern::Perl;
use IPC::System::Simple qw(capture);
use Class::Date;
use Class::CSV;
use File::Slurp qw(write_file);
use Readonly;
use Data::Dumper;

Readonly::Scalar my $COMMA     => q{,};
Readonly::Scalar my $PIPE      => qr{\|};
Readonly::Scalar my $WEEK      => q{7D};
Readonly::Scalar my $DATE_FMT  => q{%Y-%m-%d};
Readonly::Scalar my $DATA_FILE => q{report.dat};
Readonly::Scalar my $CMD       => q{sacct -P -n -a -X -s cd -S %s -E %s -o %s};

Readonly::Array my @HEADERS => (qw(jobid start end));

my $csv     = Class::CSV->new(fields => [qw(date avg_duration)]);
my $now     = Class::Date->now();
my $start   = $now - $WEEK;
my $end     = $now;
my @results = ();

for (1 .. 52) {
  my $total_jobs   = 0;
  my $total_time   = 0;
  my $avg_duration = 0;
  my $start_fmt    = $start->strftime($DATE_FMT);
  my $end_fmt      = $end->strftime($DATE_FMT);
  my $command      = sprintf $CMD, $start_fmt, $end_fmt, join($COMMA, @HEADERS);

  for my $line (capture($command)) {
    chomp($line);

    my %result = ();
    @result{@HEADERS} = split($PIPE, $line);

    my $job_start = Class::Date->new($result{start});
    my $job_end   = Class::Date->new($result{end});
    my $duration  = $job_end - $job_start;

    $total_jobs++;
    $total_time += $duration->second();
  }

  if ($total_jobs) {
    $avg_duration = sprintf '%.2f', $total_time / $total_jobs;
  }

  push @results, {date => $start_fmt, avg_duration => $avg_duration};

  $start -= $WEEK;
  $end   -= $WEEK;
}

map {$csv->add_line($_)} reverse @results;
write_file($DATA_FILE, $csv->string());
