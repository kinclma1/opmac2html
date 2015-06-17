module Opmac2html
  # Builder for tables
  class TableBuilder
    SPAN = '\\multispan'

    def initialize
      @header = true
      @table = ["\n"]
    end

    def add_row(cells)
      @table << "<tr>\n"
      cells.each do |cell|
        span_index = cell.index(SPAN)
        span = cell[span_index + SPAN.length] if span_index
        part = cell.partition SPAN
        newcell = part[0] + (span_index ? part[2][1..-1] : '')
        @table << cell_to_s([@header, newcell, span])
      end
      @table << "</tr>\n"
      @header = false
    end

    def add_caption(text)
      @table.insert 1, "<caption>#{text}</caption>\n"
    end

    def cell_to_s(cell)
      tag = cell[0] ? 'th' : 'td'
      attr = cell[2] ? " colspan=\"#{cell[2]}\"" : ''
      "<#{tag}#{attr}>#{cell[1]}</#{tag}>\n"
    end

    def to_s
      @table.join
    end
  end
end
