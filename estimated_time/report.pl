#!/usr/bin/env perl

use Modern::Perl;
use Class::Date;
use IPC::System::Simple qw(capture);
use Class::CSV;

my $date_fmt  = q{%Y-%m-%d};
my @headers   = (qw(jobid user timelimit elapsed));
my $sacct_fmt = q{sacct -n -P -a -X -s cd -o %s -S %s -E %s};

my $csv   = Class::CSV->new(fields => \@headers); 
my $end   = Class::Date->now();
my $start = $end - '1M';

my $cmd = sprintf $sacct_fmt,
  join(q{,},@headers),
  $start->strftime($date_fmt),
  $end->strftime($date_fmt);

$csv->add_line({map {$_ => $_} @headers});

my @results = ();
for my $line (capture($cmd)) {
  chomp($line);
  my %result        = ();
  @result{@headers} = split(/\|/, $line);

  # TODO - need to convert elapsed and timelimit to something useful

  $csv->add_line({map {$_ => $result{$_}} @headers});
}

say $cmd;
say $csv->string();
