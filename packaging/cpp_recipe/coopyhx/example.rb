
# remember to set RUBYLIB, e.g. RUBYLIB=$PWD ruby example.rb from build dir

require 'coopyhx'
coopy = Coopyhx
$coopy = coopy

coopy::Coopyhx::boot()
output = coopy::SimpleTable_obj.__new(10,20)
puts output.get_width

def zap(x)
  puts "Working on #{x.inspect}"
  $coopy::SimpleCell_obj::__new($coopy::Dynamic.new(x)).asDatum
end

output = coopy::SimpleTable_obj.__new(10,20);
cell = zap(16)
output.setCell(3,3,cell);
datum = output.getCell(3,3);
puts "value #{datum.toString().__CStr()}"
t1 = coopy::SimpleTable_obj.__new(3,3);
t2 = coopy::SimpleTable_obj.__new(3,3);
t1.setCell(0,0,zap("NAME"));
t1.setCell(1,0,zap("AGE"));
t1.setCell(2,0,zap("LOCATION"));
t1.setCell(0,1,zap("Paul"));
t1.setCell(1,1,zap("11"));
t1.setCell(2,1,zap("Space"));
t2.setCell(0,0,zap("NAME"));
t2.setCell(1,0,zap("AGE"));
t2.setCell(2,0,zap("LOCATION"));
t2.setCell(0,1,zap("Paul"));
t2.setCell(1,1,zap("88"));
t2.setCell(2,1,zap("Space"));
datum = t2.getCell(1,1);
puts "value2 ", datum.toString().__CStr()
puts "t1: ", t1.toString().__CStr()
puts "t2: ", t2.toString().__CStr()

table_diff = $coopy::SimpleTable_obj.__new(0,0)
cmp = $coopy::Coopy_obj.compareTables(t1.asTable,t2.asTable)
alignment = cmp.align()
puts "align: ", alignment.toString().__CStr()
flags = $coopy::CompareFlags_obj.__new()
highlighter = $coopy::TableDiff_obj.__new(alignment,flags)
highlighter.hilite(table_diff.asTable)
tab = table_diff.tableToString(table_diff.asTable)
puts "diff: ", tab.__CStr()
