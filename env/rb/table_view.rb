module Coopy
  class TableView < ::Coopy::Table
    def initialize(data)
      @data = data
      @height = data.length
      @width = 0
      @width = data[0].length if @height>0
    end

    def get_width() @width end

    def get_height() @height end

    def get_cell(x,y)
      @data[y][x]
    end

    def set_cell(x,y,c)
      @data[y][x] = c
    end

    def to_s
      ::Coopy::SimpleTable::table_to_string(self)
    end

    def get_cell_view
      ::Coopy::SimpleView.new
    end

    def is_resizable
      true
    end

    def resize(w,h)
      @width = w
      @height = h
      @data.length.times do |i|
        row = @data[i]
        row = @data[i] = [] if row.nil?
        while row.length<w
          row << nil
        end
      end
      while @data.length<h
        row = []
        w.times do |i|
          row << nil
        end
        @data << row
      end
      true
    end

    def clear
      @data.clear
      @width = 0
      @height = 0
    end

    def trim_blank
      false
    end

    def get_data
      return @data
    end

    def insert_or_delete_rows(fate,hfate)
      ndata = []
      fate.length.times do |i|
        j = fate[i];
        ndata[j] = @data[i] if j!=-1
      end
      @data.clear
      ndata.length.times do |i|
        @data[i] = ndata[i]
      end
      self.resize(@width,hfate)
      true
    end

    def insert_or_delete_columns(fate,wfate)
      if wfate==@width and wfate==fate.length
        eq = true
        wfate.times do |i|
          if fate[i]!=i
            eq = false
            break
          end
        end
        return true if eq
      end
      @height.times do |i|
        row = @data[i]
        nrow = []
        @width.times do |j|
          next if fate[j]==-1
          nrow[fate[j]] = row[j]
        end
        while nrow.length<wfate
          nrow << nil
        end
        @data[i] = nrow
      end
      @width = wfate
      if @width == 0
        @height = 0
      end
      true
    end

    def is_similar(alt)
      return false if alt.width!=@width
      return false if alt.height!=@height
      @width.times do |c|
        @height.times do |r|
          v1 = "" + self.get_cell(c,r)
          v2 = "" + alt.get_cell(c,r) 
          if (v1!=v2)
            puts("MISMATCH "+ v1 + " " + v2);
            return false
          end
        end
      end
      true
    end


    def clone
      result = TableView.new([])
      result.resize(@width,@height)
      @width.times do |c|
        @height.times do |r|
          result.set_cell(c,r,self.get_cell(c,r))
        end
      end
      result
    end

    def create
      TableView.new([])
    end

    def get_meta
      nil
    end
  end
end
