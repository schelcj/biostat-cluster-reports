#!/usr/bin/env perl

use Modern::Perl;
use Class::CSV;
use Class::Date;
use File::Slurp qw(write_file);
use IPC::System::Simple qw(capture);

my $date_fmt    = q{%Y-%m-%d};
my @headers     = (qw(jobid user timelimit elapsed));
my $sacct_fmt   = q{sacct -n -P -a -X -s cd -o %s -S %s -E %s};
my $r_data_file = q{report.dat};

my $csv   = Class::CSV->new(fields => \@headers);
my $end   = Class::Date->now();
my $start = $end - '1M';
my $cmd   = sprintf $sacct_fmt, join(q{,}, @headers), $start->strftime($date_fmt), $end->strftime($date_fmt);

push @headers, (qw(time_requested time_elapsed));

$csv->add_line({map {$_ => $_} @headers});

my @results = ();
for my $line (capture($cmd)) {
  chomp($line);
  my %result = ();
  @result{@headers} = split(/\|/, $line);

  $result{time_requested} = parse_time($result{timelimit});
  $result{time_elapsed}   = parse_time($result{elapsed});

  $csv->add_line({map {$_ => $result{$_}} @headers});
}

write_file($r_data_file, $csv->string());

sub parse_time {
  my ($time) = @_;
  my ($days, $hours, $minutes, $seconds) = (0, 0, 0, 0);

  given ($time) {
    when (/^([\d]{1,2})\-([\d]{2}):([\d]{2}):([\d]{2})/) {
      ($days, $hours, $minutes, $seconds) = ($1, $2, $3, $4);
    }
    when (/([\d]{2}):([\d]{2}):([\d]{2})/) {
      ($hours, $minutes, $seconds) = ($1, $2, $3);
    }
  }

  return (($hours + ($days * 24)) * 60) + $minutes;
}
