#!/usr/bin/env perl

use Modern::Perl;
use Class::Date;
use System::Command;
use Readonly;

Readonly::Array my @SACCT_HEADERS    => (qw(jobid user submit start end));
Readonly::Array my @SREPORT_HEADERS  => (qw(clst alloc down plnd_down idle resv rep));
Readonly::Array my @SACCTMGR_HEADERS => (qw(name account admin));

Readonly::Scalar my $COMMA       => q{,};
Readonly::Scalar my $PIPE        => q{|};
Readonly::Scalar my $DATE_FORMAT => q{%Y-%m-%d};

Readonly::Scalar my $SACCT_CMD    => sprintf q{sacct -a -n -X -s cd -P -o %s -S %%s}, join($COMMA, @SACCT_HEADERS);
Readonly::Scalar my $SREPORT_CMD  => q{sreport -n -P cluster util start=%s};
Readonly::Scalar my $SACCTMGR_CMD => q{sacctmgr -n -P show users};

my $now        = Class::Date->now();
my $start_date = $now - '1M'; ## no critic (ProhibitMismatchedOperators)
my $avg_wait   = get_avg_wait_time($start_date);
my $idle_time  = get_total_idle_time($start_date);
my $total_users = get_total_users($start_date);

say "Average waittime for all jobs for the last month is $avg_wait minutes";
say "Total CPU Minutes idle: $idle_time";
say "Total users: $total_users";

sub get_avg_wait_time {
  my ($date) = @_;
  my $command = sprintf $SACCT_CMD, $date->strftime($DATE_FORMAT);
  my @results = _get_results($command, @SACCT_HEADERS);

  my $total_wait = 0;

  foreach my $result (@results) {
    my $submit = Class::Date->new($result->{submit});
    my $start  = Class::Date->new($result->{start});
    my $diff   = $start - $submit;

    $total_wait += $diff->min;
  }

  return sprintf '%.0f', $total_wait / scalar @results;
}

sub get_total_idle_time {
  my ($date) = @_;
  my $command = sprintf $SREPORT_CMD, $date->strftime($DATE_FORMAT);
  my @results = _get_results($command, @SREPORT_HEADERS);
  return $results[0]->{idle};
}

sub get_total_users {
  my ($date)  = @_;
  my @results = _get_results($SACCTMGR_CMD, @SACCTMGR_HEADERS);
  return scalar @results;
}

sub _get_results {
  my ($command, @headers) = @_;

  my @results = ();
  my $cmd     = System::Command->new($command);
  my $stdout  = $cmd->stdout();

  while (<$stdout>) {
    chomp;
    my %result = ();
    @result{@headers} = split(/[$PIPE]/);
    push @results, \%result;
  }

  $cmd->close();
  return @results;
}
