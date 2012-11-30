#!/usr/bin/env perl

use Modern::Perl;
use HTML::Template;
use Spreadsheet::ParseExcel;
use Data::Dumper;

my $pu_ref = get_percent_util_ref();
my $tmpl   = HTML::Template->new(filename => 'report.tex.tmpl', global_vars => 1);

$tmpl->param($pu_ref);
say $tmpl->output();

sub get_percent_util_ref {
  my $parser           = Spreadsheet::ParseExcel->new();
  my $percent_util     = $parser->parse('percent_util.xls');
  my $percent_util_ref = {};

  for my $ws ($percent_util->worksheets()) {
    my ($row_min, $row_max) = $ws->row_range();
    my ($col_min, $col_max) = $ws->col_range();

    for my $row (2 .. $row_max) {
      my $col1 = $ws->get_cell($row,0)->value(); 
      my $col2 = $ws->get_cell($row,1)->value();
     
      $col1 =~ s/[_]/ /g;
      $col2 =~ s/[%]//g;

      push @{$percent_util_ref->{pu_results}}, {col1 => $col1, col2 => $col2};
    }

    $percent_util_ref->{pu_title}   = $ws->get_cell(0,0)->value();
    $percent_util_ref->{pu_col1_hd} = $ws->get_cell(1,0)->value();
    $percent_util_ref->{pu_col2_hd} = $ws->get_cell(1,1)->value();
  }

  return $percent_util_ref;
}
