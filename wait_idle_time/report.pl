#!/usr/bin/env perl

## no critic (ProhibitMismatchedOperators)

use Modern::Perl;
use Class::Date;
use System::Command;
use Readonly;
use Excel::Template;

Readonly::Array my @SACCT_HEADERS    => (qw(jobid user submit start end));
Readonly::Array my @SREPORT_HEADERS  => (qw(clst alloc down plnd_down idle resv rep));
Readonly::Array my @SACCTMGR_HEADERS => (qw(name account admin));

Readonly::Scalar my $COMMA       => q{,};
Readonly::Scalar my $PIPE        => q{|};
Readonly::Scalar my $DATE_FORMAT => q{%Y-%m-%d};
Readonly::Scalar my $TEMPLATE    => q{template.xml};
Readonly::Scalar my $REPORT      => q{wait_idle_time.xls};
Readonly::Scalar my $MAX_MONTHS  => 12;

Readonly::Scalar my $SACCT_CMD    => sprintf q{sacct -a -n -X -s cd -P -o %s -S %%s -E %%s}, join($COMMA, @SACCT_HEADERS);
Readonly::Scalar my $SREPORT_CMD  => q{sreport -n -P cluster util start=%s end=%s};
Readonly::Scalar my $SACCTMGR_CMD => q{sacctmgr -n -P show users};

my $excel       = Excel::Template->new(filename => $TEMPLATE);
my $now         = Class::Date->now();
my $start_date  = $now - '1M';
my $end_date    = $now;
my $total_users = get_total_users();
my $params      = {};

for (1..$MAX_MONTHS) {
  my $avg_wait = get_avg_wait_time($start_date,$end_date);
  my $idle_ref = get_total_idle_time($start_date,$end_date);

  push @{$params->{results}}, {
    total_users => $total_users,
    avg_wait    => $avg_wait,
    idle_time   => $idle_ref->{time},
    idle_perc   => $idle_ref->{percent},
    start_date  => $start_date->strftime($DATE_FORMAT),
    end_date    => $end_date->strftime($DATE_FORMAT),
  };

  $start_date = $start_date - '1M';
  $end_date   = $end_date   - '1M';
}

$excel->param($params);
$excel->write_file($REPORT);

sub get_avg_wait_time {
  my ($start,$end) = @_;

  my $command    = sprintf $SACCT_CMD, $start->strftime($DATE_FORMAT), $end->strftime($DATE_FORMAT);
  my @results    = _get_results($command, @SACCT_HEADERS);
  my $total_wait = 0;

  foreach my $result (@results) {
    my $job_submit = Class::Date->new($result->{submit});
    my $job_start  = Class::Date->new($result->{start});
    my $diff       = $job_start - $job_submit;

    $total_wait += $diff->min;
  }

  return sprintf '%.0f', $total_wait / scalar @results;
}

sub get_total_idle_time {
  my ($start,$end) = @_;

  my $command   = sprintf $SREPORT_CMD, $start->strftime($DATE_FORMAT), $end->strftime($DATE_FORMAT);
  my ($results) = _get_results($command, @SREPORT_HEADERS);
  my $percent   = sprintf '%.2f', (($results->{idle} / $results->{rep}) * 100); ## no critic (ProhibitMagicNumbers)

  return {'time' => $results->{idle}, 'percent' => $percent};
}

sub get_total_users {
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
