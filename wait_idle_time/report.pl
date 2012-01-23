#!/usr/bin/env perl

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

Readonly::Scalar my $SACCT_CMD    => sprintf q{sacct -a -n -X -s cd -P -o %s -S %%s}, join($COMMA, @SACCT_HEADERS);
Readonly::Scalar my $SREPORT_CMD  => q{sreport -n -P cluster util start=%s};
Readonly::Scalar my $SACCTMGR_CMD => q{sacctmgr -n -P show users};

my $now         = Class::Date->now();
my $excel       = Excel::Template->new(filename => $TEMPLATE);
my $start_date  = $now - '1M'; ## no critic (ProhibitMismatchedOperators)
my $avg_wait    = get_avg_wait_time($start_date);
my $idle_ref    = get_total_idle_time($start_date);
my $total_users = get_total_users($start_date);

$excel->param({
  total_users => $total_users,
  avg_wait    => $avg_wait,
  idle_time   => $idle_ref->{time},
  idle_perc   => $idle_ref->{percent},
  start_date  => $start_date->strftime($DATE_FORMAT),
  end_date    => $now->strftime($DATE_FORMAT),
});
$excel->write_file($REPORT);

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

  my $command   = sprintf $SREPORT_CMD, $date->strftime($DATE_FORMAT);
  my ($results) = _get_results($command, @SREPORT_HEADERS);
  my $percent   = sprintf '%.2f', (($results->{idle} / $results->{rep}) * 100); ## no critic (ProhibitMagicNumbers)

  return {'time' => $results->{idle}, 'percent' => $percent};
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
