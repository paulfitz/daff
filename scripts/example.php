<?php

if(version_compare(PHP_VERSION, '5.1.0', '<')) {
    exit('Your current PHP version is: ' . PHP_VERSION . '. Haxe/PHP generates code for version 5.1.0 or later');
}

require_once dirname(__FILE__).'/lib/php/Boot.class.php';

$data1 = [
  ['Country','Capital'],
  ['Ireland','Dublin'],
  ['France','Paris'],
  ['Spain','Barcelona']
  ];

$data2 = [
  ['Country','Code','Capital'],
  ['Ireland','ie','Dublin'],
  ['France','fr','Paris'],
  ['Spain','es','Madrid'],
  ['Germany','de','Berlin']
  ];

$table1 = new coopy_PhpTableView($data1);
$table2 = new coopy_PhpTableView($data2);

$alignment = coopy_Coopy::compareTables($table1,$table2)->align();

$data_diff = [];
$table_diff = new coopy_PhpTableView($data_diff);

$flags = new coopy_CompareFlags();
$highlighter = new coopy_TableDiff($alignment,$flags);
$highlighter->hilite($table_diff);

$diff2html = new coopy_DiffRender();
$diff2html->usePrettyArrows(false);
$diff2html->render($table_diff);
$table_diff_html = $diff2html->html();
echo $table_diff_html;


$patcher = new coopy_HighlightPatch($table1,$table_diff);
$patcher->apply();

?>