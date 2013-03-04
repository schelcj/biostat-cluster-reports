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
Readonly::Scalar my $MONTH     => q{1M};
Readonly::Scalar my $DATE_FMT  => q{%Y-%m-%d};
Readonly::Scalar my $DATA_FILE => q{report.dat};
Readonly::Scalar my $CMD       => q{sacct -P -n -a -X -s cd -S %s -E %s -o %s};

Readonly::Array my @HEADERS => (qw(jobid submit start end));

my $csv     = Class::CSV->new(fields => [qw(jobid waittime duration)]);
my $now     = Class::Date->now();
my $start   = $now - $MONTH;
my $end     = $now;
my @results = ();

$csv->add_line({jobid => 'jobid', waittime => 'waittime', duration => 'duration'});

my $start_fmt = $start->strftime($DATE_FMT);
my $end_fmt   = $end->strftime($DATE_FMT);
my $command   = sprintf $CMD, $start_fmt, $end_fmt, join($COMMA, @HEADERS);

for (capture($command)) {
  chomp;

  my %result = ();
  @result{@HEADERS} = split($PIPE);

  my $job_submit = Class::Date->new($result{submit});
  my $job_start  = Class::Date->new($result{start});
  my $job_end    = Class::Date->new($result{end});
  my $duration   = $job_end - $job_start;
  my $waittime   = $job_start - $job_submit;

  $csv->add_line({jobid => $result{jobid}, waittime => $waittime, duration => $duration});
}

write_file($DATA_FILE, $csv->string());
