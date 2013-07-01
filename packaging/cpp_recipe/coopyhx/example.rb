
# remember to set RUBYLIB, e.g. RUBYLIB=$PWD ruby example.rb from build dir

require 'coopyhx'
coopy = Coopyhx
$coopy = coopy

coopy::Coopyhx::boot()
output = coopy::SimpleTable.new(10,20)
puts output.get_width

def zap(x)
  puts "Working on #{x.inspect}"
  x
end

output = coopy::SimpleTable.new(10,20)
view = output.getCellView()
cell = zap(16)
output.setCell(3,3,cell)
datum = output.getCell(3,3)
puts datum.to_s
puts "value #{datum.to_s}"
t1 = coopy::SimpleTable.new(3,3)
t2 = coopy::SimpleTable.new(3,3)
t1.setCell(0,0,zap("NAME"))
t1.setCell(1,0,zap("AGE"))
t1.setCell(2,0,zap("LOCATION"))
t1.setCell(0,1,zap("Paul"))
t1.setCell(1,1,zap("11"))
t1.setCell(2,1,zap("Space"))
t2.setCell(0,0,zap("NAME"))
t2.setCell(1,0,zap("AGE"))
t2.setCell(2,0,zap("LOCATION"))
t2.setCell(0,1,zap("Paul"))
t2.setCell(1,1,zap("88"))
t2.setCell(2,1,zap("Space"))
datum = t2.getCell(1,1)
puts "value2 ", datum.to_s
puts "t1: ", t1.to_s
puts "t2: ", t2.to_s

table_diff = $coopy::SimpleTable.new(0,0)
cmp = $coopy::Coopy.compareTables(t1.asTable,t2.asTable)
alignment = cmp.align()
puts "align: ", alignment.toString
flags = $coopy::CompareFlags.new
highlighter = $coopy::TableDiff.new(alignment,flags)
highlighter.hilite(table_diff.asTable)
tab = $coopy::SimpleTable.tableToString(table_diff.asTable)
puts "diff: ", tab


t1.setCell(0,0,10)
v = t1.getCellView()
puts t1.getCell(0,0).asInt.inspect
puts v.toString(t1.getCell(0,0))

