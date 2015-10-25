require 'daff'

data1 = [
    ['Country','Capital'],
    ['Ireland','Dublin'],
    ['France','Paris'],
    ['Spain','Barcelona']
]

data2 = [
    ['Country','Code','Capital'],
    ['Ireland','ie','Dublin'],
    ['France','fr','Paris'],
    ['Spain','es','Madrid'],
    ['Germany','de','Berlin']
]

table_diff = Daff::Coopy.diff(data1,data2)

if table_diff.get_height != 6
  puts "Wrong height"
  exit(1)
end

if table_diff.get_width != 4
  puts "Wrong width"
  exit(1)
end


