#!/usr/bin/env perl

use Modern::Perl;
use Class::Date;
use System::Command;
use Readonly;
use Data::Dumper;

Readonly::Scalar my $COMMA       => q{,};
Readonly::Scalar my $PIPE        => q{|};
Readonly::Scalar my $DATE_FORMAT => q{%Y-%m-%d};
Readonly::Scalar my $SACCT_CMD   => q{sacct -a -n -X -s cd -P -S %s -o %s};

Readonly::Array my @HEADERS      => (qw(jobid user submit start end));

my $now        = Class::Date->now();
my $start_date = $now - '1M';
my $command    = get_command($start_date);
my @results    = get_results($command);
my $total_wait = get_total(@results);
my $total_jobs = scalar @results;
my $avg_wait   = sprintf '%.0f', $total_wait / $total_jobs;

say "Total jobs completed in the last month $total_jobs"; 
say "Average waittime for all jobs for the last month is $avg_wait minutes";

sub get_command {
  my ($date) = @_;
  return sprintf $SACCT_CMD, $date->strftime($DATE_FORMAT), join($COMMA, @HEADERS);
}

sub get_results {
  my ($command) = @_;
  my @results   = ();
  my $cmd       = System::Command->new($command);
  my $stdout    = $cmd->stdout();

  while (<$stdout>) {
    chomp;
    my %record = ();
    @record{@HEADERS} = split(/[$PIPE]/);
    push @results, \%record;
  }

  $cmd->close();
  return @results;
}

sub get_total {
  my (@results) = @_;
  my $total     = 0;

  foreach my $result (@results) {
    my $submit = Class::Date->new($result->{submit});
    my $start  = Class::Date->new($result->{start});
    my $diff   = $start - $submit;

    $total += $diff->min;
  }

  return $total;
}
