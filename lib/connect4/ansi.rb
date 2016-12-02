require 'connect4'

module Connect4
  module Ansi
    class Board < Connect4::Board
      def to_s
        off    = "\e[0m"
        yellow = "\e[48;5;#{16+6*6*5}m"
        red    = "\e[48;5;#{16+6*6*5+6*5}m"
        blue   = "\e[48;5;#{16+5}m"
        black  = "\e[48;5;16m"
        vsep   = "#{blue} #{off}"
        hsep   = "#{blue}#{' '*(width*3+1)}#{off}\n"
        tiles  = {
          tile1 => red    + "  " + off,
          tile2 => yellow + "  " + off,
          nil   => black  + "  " + off,
        }
        ansi_rows = to_a.map { |row|
          cols = row.map { |tile| tiles[tile] }.join(vsep)
          "#{vsep}#{cols}#{vsep}\n"
        }
        column_labels = vsep + blue + width.times.map { |i| i.to_s.ljust 2 }.join(' ') + vsep
        "#{hsep}#{ansi_rows.join hsep}#{column_labels}"
      end
    end
  end
end
