#!/usr/bin/env perl

use Modern::Perl;
use HTML::Template;
use Spreadsheet::ParseExcel;
use File::Slurp qw(write_file);
use POSIX qw(strftime);
use Class::CSV;
use List::MoreUtils qw(part);

my $tmpl      = HTML::Template->new(filename => 'report.tex.tmpl', global_vars => 1);
my %pu        = get_percent_util();
my %pum       = get_percent_util_by_month();
my %tu        = get_top_usage();
my %quat_wit  = get_quantile_waittime();
my $param_ref = {%pu, %pum, %tu, %quat_wit};

$param_ref->{date} = strftime('%B %Y', localtime());

$tmpl->param($param_ref);

write_file('report.tex', $tmpl->output());

sub get_percent_util {
  my $parser   = Spreadsheet::ParseExcel->new();
  my $workbook = $parser->parse('percent_util.xls');
  my %results  = ();

  for my $worksheet ($workbook->worksheets()) {
    my ($row_min, $row_max) = $worksheet->row_range();

    for my $row (2 .. $row_max) {
      my $col1 = $worksheet->get_cell($row, 0)->value();
      my $col2 = $worksheet->get_cell($row, 1)->value();

      $col1 =~ s/[_]/ /g;
      $col2 =~ s/[%]//g;

      push @{$results{pu_results}}, {col1 => $col1, col2 => $col2};
    }

    $results{pu_title}   = $worksheet->get_cell(0, 0)->value();
    $results{pu_col1_hd} = $worksheet->get_cell(1, 0)->value();
    $results{pu_col2_hd} = $worksheet->get_cell(1, 1)->value();
  }

  return %results;
}

sub get_percent_util_by_month {
  my $parser   = Spreadsheet::ParseExcel->new();
  my $workbook = $parser->parse('percent_util_by_month.xls');
  my %results  = ();

  for my $worksheet ($workbook->worksheets()) {
    my ($row_min, $row_max) = $worksheet->row_range();
    my ($col_min, $col_max) = $worksheet->col_range();

    for ($col_min .. $col_max) {
      my $key = 'pum_col' . $_ . '_hd';
      $results{$key} = $worksheet->get_cell(1, $_)->value();
    }

    for my $row (2 .. $row_max) {
      my $col_ref = {};

      for my $col ($col_min .. $col_max) {
        $col_ref->{qq{col$col}} = $worksheet->get_cell($row, $col)->value();
      }

      push @{$results{pum_results}}, $col_ref;
    }

    $results{pum_title} = $worksheet->get_cell(0, 0)->value();
  }

  return %results;
}

sub get_top_usage {
  my $parser   = Spreadsheet::ParseExcel->new();
  my $workbook = $parser->parse('top_usage.xls');
  my %results  = ();

  for my $worksheet ($workbook->worksheets()) {
    my ($row_min, $row_max) = $worksheet->row_range();
    my ($col_min, $col_max) = $worksheet->col_range();

    for ($col_min .. $col_max) {
      my $key = 'tu_col' . $_ . '_hd';
      $results{$key} = $worksheet->get_cell(1, $_)->value();
    }

    for my $row (2 .. $row_max) {
      my $col_ref = {};

      for my $col ($col_min .. $col_max) {
        $col_ref->{qq{col$col}} = $worksheet->get_cell($row, $col)->value();
      }

      push @{$results{tu_results}}, $col_ref;
    }



    $results{tu_title} = $worksheet->get_cell(0, 0)->value();
  }

  return %results;
}

sub get_quantile_waittime {
  my $csv     = Class::CSV->parse(
    filename => 'duration_vs_waittime.csv',
    fields   => [qw(jobid waittime duration)]
  );

  my @lines = @{$csv->lines()};
  shift @lines;

  my ($i,$j)    = (0,0);
  my @waittimes = sort {$a <=> $b} map {int($_->waittime * 60)} @lines;
  my @durations = sort {$a <=> $b} map {int($_->duration * 60)} @lines;
  my $quarter   = scalar @waittimes / 4;
  my @wit_parts = part {int($i++ / $quarter)} @waittimes;
  my @dur_parts = part {int($j++ / $quarter)} @durations;

  my %results = (
    quan_wit_first  => $wit_parts[0][-1],
    quan_dur_first  => $dur_parts[0][-1],

    quan_wit_second => $wit_parts[1][-1],
    quan_dur_second => $dur_parts[1][-1],

    quan_wit_third  => $wit_parts[2][-1],
    quan_dur_third  => $dur_parts[2][-1],

    quan_wit_fourth => $wit_parts[3][-1],
    quan_dur_fourth => $dur_parts[3][-1],
  );

  return %results;
}
