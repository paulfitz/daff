#!/usr/bin/env ruby

require_relative 'daff'

table1 = [
  ['Country','Capital'],
  ['Ireland','Dublin'],
  ['France','Paris'],
  ['Spain','Barcelona']
  ]

table2 = [
  ['Country','Code','Capital'],
  ['Ireland','ie','Dublin'],
  ['France','fr','Paris'],
  ['Spain','es','Madrid'],
  ['Germany','de','Berlin']
  ]

alignment = Daff::Coopy.compare_tables(table1,table2).align()

table_diff = []

flags = Daff::CompareFlags.new
highlighter = Daff::TableDiff.new(alignment,flags)
highlighter.hilite(table_diff)

diff2html = Daff::DiffRender.new
diff2html.use_pretty_arrows(false)
diff2html.render(table_diff)
table_diff_html = diff2html.html
puts table_diff_html
