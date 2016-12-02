module Connect4
  class Board
    attr_reader :width, :height, :win_length, :tile1, :tile2, :crnt_move

    def initialize(
        width,
        height,
        win_length,
        tile1,
        tile2,
        array = Array.new(width*height),
        crnt_move = 0
      )
      @width      = width
      @height     = height
      @tile1      = tile1
      @tile2      = tile2
      @crnt_move  = crnt_move
      @win_length = win_length
      @array      = array
    end

    def to_a
      @array.each_slice(width).to_a
    end

    def move(column_no)
      new_array = @array.dup
      y = 0
      x = column_no
      y += 1 while y < height && !new_array[y*width + column_no]
      y -= 1
      if y < 0
        require "pry"
        binding.pry
      end
      new_array[y*width + column_no] = current_player
      self.class.new width, height, win_length, tile1, tile2, new_array, crnt_move+1
    end

    def to_s
      str = ""
      height.times.map do |y|
        str << "|"
        width.times.map do |x|
          element = @array[y*width+x]
          str << "#{element||' '}|"
        end
        str << "\n"
      end
      str
    end

    def current_player
      return tile1 if crnt_move.even?
      tile2
    end

    def next_player
      return tile2 if crnt_move.odd?
      tile1
    end

    def over?
      available_columns.empty? || winner
    end

    def available_columns
      width.times.reject { |i| @array[i] }
    end

    def winner
      # check the row
      height.times do |ystart|
        (width-win_length+1).times do |xstart|
          winner = segment_winner ystart, xstart, 1
          return winner if winner
        end
      end

      # check the col
      (height-win_length+1).times do |ystart|
        width.times do |xstart|
          winner = segment_winner ystart, xstart, width
          return winner if winner
        end
      end

      # check the diagonals
      (height-win_length+1).times do |ystart|
        (width-win_length+1).times do |xstart|
          # to the lower right
          winner = segment_winner ystart, xstart, width+1
          return winner if winner

          # to the upper right
          winner = segment_winner (height-ystart-1), xstart, 1-width
          return winner if winner
        end
      end
      nil
    end

    def segment_winner(ystart, xstart, get_next)
      tile = @array[ystart*width+xstart]
      wins = win_length.times.all? do |offset|
        tile == @array[ystart*width + xstart + get_next*offset]
      end
      tile if wins
    end
  end



  class Robot
    attr_reader :board
    def initialize(board)
      @board = board
    end

    def best_move
      @prynow = true
      move, result = best_move_and_result board
      move
    end

    private

    def best_move_and_result(board, indentation=0)
      # puts board.to_s.gsub(/^/, '  '*indentation)
      # if @prynow
      #   require "pry"
      #   binding.pry
      #   @prynow=false
      # end

      # don't try to play on a board that is over
      me  = board.current_player
      you = board.next_player

      # require "pry"
      # binding.pry
      # play out the game for each available move
      moves_to_boards = board.available_columns.map do |col|
        new_board = board.move(col)
        winner    = new_board.winner
        return col, :won if winner == me # take the win
        [col, new_board]
      end

      moves = moves_to_boards.map do |col, new_board|
        winner = new_board.winner
        if winner == you # we lost
          [col, :lost]
        else
          # if we can keep playing on this board, find out what the opponent's result will be
          move, result = best_move_and_result new_board, indentation+1

          # if our opponent lost, we won
          return col, :won if result == :lost

          # otherwise, we either lost or drew
          [col, result == :won ? :lost : :draw]
        end
      end

      # it is a draw if there are no moves
      return nil, :draw if moves.empty?

      # take the draw if it exists
      moves.each { |col, result| return col, result if result == :draw }

      # take the loss if it exists
      moves.each { |col, result| return col, result }

      raise "this shouldn't be possible"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  def print_board(board)
    off    = "\e[0m"
    yellow = "\e[48;5;#{16+6*6*5}m"
    red    = "\e[48;5;#{16+6*6*5+6*5}m"
    blue   = "\e[48;5;#{16+5}m"
    black  = "\e[48;5;16m"
    substitutions = {
      board.tile1.to_s => "#{red}  #{off}",
      board.tile2.to_s => "#{yellow}  #{off}",
      " "              => "#{black}  #{off}",
      "|"              => "#{blue} #{off}",
      "\n"             => "\n#{blue}#{' '*(board.width*3+1)}#{off}\n",
    }
    puts ("\n#{board}").chars.map { |char| substitutions[char] || char }.join
  end

  board = Connect4::Board.new 4, 4, 3, :a, :b
  until board.over?
    # robot move
    move = Connect4::Robot.new(board).best_move
    break unless move
    board = board.move move
    break if board.over?

    # human move
    print_board board
    print "Enter a move: "
    move = nil
    available = board.available_columns
    move = gets.to_i while available.any? && !available.include?(move)
    board = board.move move
    break if board.over?
  end

  print_board board
  puts "Game over, winer: #{board.winner}"
end
