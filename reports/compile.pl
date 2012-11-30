#!/usr/bin/env perl

use Modern::Perl;
use HTML::Template;
use Spreadsheet::ParseExcel;
use File::Slurp qw(write_file);
use Data::Dumper;

my %pu        = get_percent_util();
my $tmpl      = HTML::Template->new(filename => 'report.tex.tmpl', global_vars => 1);
my $param_ref = {%pu};

$tmpl->param($param_ref);

write_file('report.tex', $tmpl->output());

sub get_percent_util {
  my $parser       = Spreadsheet::ParseExcel->new();
  my $percent_util = $parser->parse('percent_util.xls');
  my %results      = ();

  for my $ws ($percent_util->worksheets()) {
    my ($row_min, $row_max) = $ws->row_range();

    for my $row (2 .. $row_max) {
      my $col1 = $ws->get_cell($row,0)->value(); 
      my $col2 = $ws->get_cell($row,1)->value();
     
      $col1 =~ s/[_]/ /g;
      $col2 =~ s/[%]//g;

      push @{$results{pu_results}}, {col1 => $col1, col2 => $col2};
    }

    $results{pu_title}   = $ws->get_cell(0,0)->value();
    $results{pu_col1_hd} = $ws->get_cell(1,0)->value();
    $results{pu_col2_hd} = $ws->get_cell(1,1)->value();
  }

  return %results;
}
