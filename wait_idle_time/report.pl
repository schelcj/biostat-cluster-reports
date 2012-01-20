#!/usr/bin/env perl

use Modern::Perl;
use Class::Date;
use System::Command;
use Readonly;
use Data::Dumper;

Readonly::Array my @SACCT_HEADERS   => (qw(jobid user submit start end));
Readonly::Array my @SREPORT_HEADERS => (qw(clst alloc down plnd_down idle resv rep));

Readonly::Scalar my $COMMA       => q{,};
Readonly::Scalar my $PIPE        => q{|};
Readonly::Scalar my $DATE_FORMAT => q{%Y-%m-%d};

Readonly::Scalar my $SACCT_CMD   => sprintf q{sacct -a -n -X -s cd -P -o %s -S %%s}, join($COMMA, @SACCT_HEADERS);
Readonly::Scalar my $SREPORT_CMD => q{sreport -n -P cluster util start=%s};

my $now          = Class::Date->now();
my $start_date   = $now - '1M';
my @wait_results = get_results($start_date, $SACCT_CMD, @SACCT_HEADERS);
my $avg_wait     = get_avg_wait_time(@wait_results);

say 'Total jobs completed in the last month ' . scalar @wait_results;
say "Average waittime for all jobs for the last month is $avg_wait minutes";

sub get_results {
  my ($date, $cmd_fmt, @headers) = @_;

  my @results = ();
  my $command = sprintf $cmd_fmt, $date->strftime($DATE_FORMAT);
  my $cmd     = System::Command->new($command);
  my $stdout  = $cmd->stdout();

  while (<$stdout>) {
    chomp;
    my %record = ();
    @record{@headers} = split(/[$PIPE]/);
    push @results, \%record;
  }

  $cmd->close();
  return @results;
}

sub get_avg_wait_time {
  my (@results)  = @_;
  my $total_wait = 0;

  foreach my $result (@results) {
    my $submit = Class::Date->new($result->{submit});
    my $start  = Class::Date->new($result->{start});
    my $diff   = $start - $submit;

    $total_wait += $diff->min;
  }

  return sprintf '%.0f', $total_wait / scalar @results;
}
