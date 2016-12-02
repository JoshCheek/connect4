module Connect4
  class Board
    attr_reader :width, :height, :win_length, :tile1, :tile2, :crnt_move

    def initialize(width, height, win_length, tile1, tile2,
                   array=Array.new(width*height), crnt_move=0)
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
      raise "Can\'t move into full column" if y < 0
      new_array[y*width + column_no] = current_player
      self.class.new(width, height, win_length, tile1, tile2, new_array, crnt_move+1)
    end

    def current_player
      crnt_move.even? ? tile1 : tile2
    end

    def next_player
      crnt_move.odd? ? tile1 : tile2
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
      us   = board.current_player
      them = board.next_player

      # play the game for each available move, take it if we win there
      moves_to_boards = board.available_columns.map do |col|
        new_board = board.move(col)
        winner    = new_board.winner
        return col, :won if winner == us # take the win immediately
        [col, new_board]
      end

      # we didn't immediately win, so play the game out to see if we eventually win
      moves = moves_to_boards.map do |col, new_board|
        winner = new_board.winner
        # we lost
        next [col, :lost] if winner == them

        # if we can keep playing on this board, find out what their result will be
        move, their_result = best_move_and_result new_board, indentation+1

        # if they lost, we won, take it immediately
        return col, :won if their_result == :lost

        # we either lost or drew
        [col, their_result == :won ? :lost : :drew]
      end

      # we drew if there are no moves
      return nil, :drew if moves.empty?

      # take the draw if it exists
      moves.each { |col, result| return col, result if result == :drew }

      # take the loss if it exists (this is kind of dumb b/c it considers all losses equivalent,
      # since it cannot win if it goes second, it considers all moves equivalent instead of
      # blocking you when you're about to win)
      moves.each { |col, result| return col, result }

      raise "this shouldn't be possible"
    end
  end
end
