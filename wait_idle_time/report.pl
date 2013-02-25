#!/usr/bin/env perl

## no critic (ProhibitMismatchedOperators)

use Modern::Perl;
use Class::Date;
use System::Command;
use Readonly;
use Excel::Template;
use File::Slurp qw(write_file append_file);
use Class::CSV;

Readonly::Array my @SACCT_HEADERS    => (qw(jobid user submit start end));
Readonly::Array my @SREPORT_HEADERS  => (qw(clst alloc down plnd_down idle resv rep));
Readonly::Array my @SACCTMGR_HEADERS => (qw(name account admin));
Readonly::Array my @R_DATA_HEADERS   => (qw(start_date avg_wait avg_job_duration total_jobs));

Readonly::Scalar my $COMMA       => q{,};
Readonly::Scalar my $PIPE        => q{|};
Readonly::Scalar my $DATE_FORMAT => q{%Y-%m-%d};
Readonly::Scalar my $TEMPLATE    => q{template.xml};
Readonly::Scalar my $REPORT      => q{wait_idle_time.xls};
Readonly::Scalar my $MAX_WEEKS   => 52;
Readonly::Scalar my $R_DATA_FILE => q{waittime.dat};

Readonly::Scalar my $SACCT_CMD    => sprintf q{sacct -a -n -X -s cd -P -o %s -S %%s -E %%s}, join($COMMA, @SACCT_HEADERS);
Readonly::Scalar my $SREPORT_CMD  => q{sreport -n -P cluster util start=%s end=%s};
Readonly::Scalar my $SACCTMGR_CMD => q{sacctmgr -n -P show users};

my $now         = Class::Date->now();
my $start_date  = $now - '7D';
my $end_date    = $now;
my $total_users = get_total_users();
my @results     = ();
my $params      = {
  total_users   => $total_users,
};

for (1 .. $MAX_WEEKS) {
  my $avg_wait         = get_avg_wait_time($start_date, $end_date);
  my $avg_job_duration = get_avg_job_duration($start_date, $end_date);
  my $idle_ref         = get_total_idle_time($start_date, $end_date);
  my $total_jobs       = get_total_jobs($start_date, $end_date);

  push @results, {
         avg_wait         => $avg_wait,
         avg_job_duration => $avg_job_duration,
         total_jobs       => $total_jobs,
         idle_time        => $idle_ref->{time},
         idle_perc        => $idle_ref->{percent},
         start_date       => $start_date->strftime($DATE_FORMAT),
       };

  $start_date = $start_date - '7D';
  $end_date   = $end_date - '7D';
}

@{$params->{results}} = sort {$a->{start_date} cmp $b->{start_date}} @results;

write_r_data();
write_excel();

exit;

sub write_excel {
  my $excel = Excel::Template->new(filename => $TEMPLATE);

  $excel->param($params);
  $excel->write_file($REPORT);

  return;
}

sub write_r_data {
  my $r_dat = Class::CSV->new(fields => \@R_DATA_HEADERS);
  my $header_row = {map { $_ => $_} @R_DATA_HEADERS};

  $r_dat->add_line($header_row);

  foreach my $result (@{$params->{results}}) {
    my $result_row = {map {$_ => $result->{$_}} @R_DATA_HEADERS};
    $r_dat->add_line($result_row);
  }

  write_file($R_DATA_FILE, $r_dat->string());

  return;
}

sub get_avg_wait_time {
  my ($start, $end) = @_;

  my $command = sprintf $SACCT_CMD, $start->strftime($DATE_FORMAT), $end->strftime($DATE_FORMAT);
  my @results = _get_results($command, @SACCT_HEADERS);
  my $total_wait = 0;

  foreach my $result (@results) {
    my $job_submit = Class::Date->new($result->{submit});
    my $job_start  = Class::Date->new($result->{start});
    my $diff       = $job_start - $job_submit;

    $total_wait += $diff->min;
  }

  return 0 if scalar @results <= 0;
  return sprintf '%.0f', $total_wait / scalar @results;
}

sub get_avg_job_duration {
  my ($start, $end) = @_;

  my $command = sprintf $SACCT_CMD, $start->strftime($DATE_FORMAT), $end->strftime($DATE_FORMAT);
  my @results = _get_results($command, @SACCT_HEADERS);
  my $total_duration = 0;

  foreach my $result (@results) {
    my $job_start = Class::Date->new($result->{start});
    my $job_end   = Class::Date->new($result->{end});
    my $diff      = $job_end - $job_start;

    $total_duration += $diff->min;
  }

  return 0 if scalar @results <= 0;
  return sprintf '%.0f', $total_duration / scalar @results;
}

sub get_total_jobs {
  my ($start, $end) = @_;

  my $command = sprintf $SACCT_CMD, $start->strftime($DATE_FORMAT), $end->strftime($DATE_FORMAT);
  my @results = _get_results($command, @SACCT_HEADERS);

  return scalar @results;
}

sub get_total_idle_time {
  my ($start, $end) = @_;

  my $command = sprintf $SREPORT_CMD, $start->strftime($DATE_FORMAT), $end->strftime($DATE_FORMAT);
  my ($results) = _get_results($command, @SREPORT_HEADERS);

  my $percent = 0;
  if ( $results->{rep} ) {
    $percent = sprintf '%.2f', (($results->{idle} / $results->{rep}) * 100);    ## no critic (ProhibitMagicNumbers)
  }

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
