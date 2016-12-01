require 'connect4'

RSpec.describe 'Connect4' do
  def assert_winner(winner, win_length, rows)
    tile1, tile2 = :a, :b
    board = Connect4::Board.new(
      rows[0].length,
      rows.length,
      win_length,
      tile1,
      tile2,
      rows.flatten
    )
    expect(board.winner).to eq winner
  end


  example 'Board knows the winner' do
    tile1, tile2 = :a, :b

    # empty
    assert_winner nil, 2, [[nil, nil, nil], [nil, nil, nil], [nil, nil, nil]]

    # no one wins after one and two moves
    9.times.each do |a_move|
      array = Array.new 9
      array[a_move] = :a
      assert_winner nil, 2, array.each_slice(3).to_a
      9.times.each do |b_move|
        next if array[b_move]
        array[b_move] = :b
        assert_winner nil, 2, array.each_slice(3).to_a
        array[b_move] = nil
      end
    end

    # after 3 moves, there are some wins
    # horizonatal on each row
    assert_winner :a, 2, [[:a, :a, :b], [nil, nil, nil], [nil, nil, nil]]
    assert_winner :a, 2, [[:b, :a, :a], [nil, nil, nil], [nil, nil, nil]]
    assert_winner :a, 2, [[:b, nil, nil], [:a, :a, nil], [nil, nil, nil]]
    assert_winner :a, 2, [[:b, nil, nil], [nil, nil, nil], [:a, :a, nil]]
    assert_winner nil, 2, [[:a, nil, :a], [:b, nil, nil], [nil, nil, nil]]
    assert_winner nil, 2, [[:a, :b, :a], [nil, nil, nil], [nil, nil, nil]]

    # vertical on each col
    assert_winner :a, 2, [[:a, nil, nil], [:a, nil, nil], [:b, nil, nil]]
    assert_winner :a, 2, [[:b, nil, nil], [:a, nil, nil], [:a, nil, nil]]
    assert_winner :a, 2, [[:b, :a, nil], [nil, :a, nil], [nil, nil, nil]]
    assert_winner :a, 2, [[:b, nil, :a], [nil, nil, :a], [nil, nil, nil]]
    assert_winner nil, 2, [[:a, nil, nil], [:b, nil, nil], [:a, nil, nil]]

    # diagonally
    assert_winner :a, 2, [[:a, :b, nil],
                          [nil, :a, nil],
                          [nil, nil, nil]]
    assert_winner :a, 2, [[nil, :b, nil],
                          [nil, :a, nil],
                          [nil, nil, :a]]
    assert_winner :a, 2, [[nil, :b, nil],
                          [:a, nil, nil],
                          [nil, :a, nil]]
    assert_winner :a, 2, [[nil, :a, nil],
                          [:b, nil, :a],
                          [nil, nil, nil]]
    assert_winner :a, 2, [[nil, :a, nil],
                          [:a, nil, :b],
                          [nil, nil, nil]]
    assert_winner :a, 2, [[nil, :b, nil],
                          [nil, nil, :a],
                          [nil, :a, nil]]
    assert_winner nil, 2, [[:a, :b, nil],
                           [nil, nil, nil],
                           [nil, nil, :a]]
    assert_winner nil, 2, [[nil, :b, :a],
                           [nil, nil, nil],
                           [:a, nil, nil]]

    # when b wins
    assert_winner :b, 2, [[:b, :b, :a], [:a, nil, nil], [nil, nil, nil]]

    # when it takes more than 2 in a row to win
    assert_winner :a, 3, [[:a, :a, :a], [:b, :b, nil], [nil, nil, nil]]
    assert_winner nil, 3, [[:a, :a, nil], [:b, :b, :a], [nil, nil, nil]]

    # board with different number of rows and cols
    assert_winner :a, 4, [
      [:a, :a, :a, :a],
      [:b, :b, :b, nil],
      [nil, nil, nil, nil],
    ]
    assert_winner nil, 4, [
      [:a, :a, :a, nil],
      [:b, :b, :b, nil],
      [nil, nil, nil, nil],
    ]
    assert_winner :a, 3, [
      [:a, :b, nil, nil],
      [:a, :b, nil, nil],
      [:a, nil, nil, nil],
    ]
    assert_winner nil, 3, [
      [:a, :b, :a, :a],
      [nil, :b, nil, nil],
      [nil, nil, nil, nil],
    ]
  end

  example 'acceptance' do
    tile1, tile2  = :a, :b

    # a x=4, y=4 board, we need 3 to win
    start_board = Connect4::Board.new 4, 4, 3, tile1, tile2
    expect(start_board.to_a).to eq [
      [nil, nil, nil, nil],
      [nil, nil, nil, nil],
      [nil, nil, nil, nil],
      [nil, nil, nil, nil],
    ]

    # play out every possible game, it should win them all
    unfinished = [start_board]
    while unfinished.any?
      board = unfinished.shift
      board = board.move Connect4::Robot.new(board).best_move
      if board.winner
        expect(board.winner).to eq :a if board.winner
      else
        board.available_columns.each { |col| unfinished << board.move(col) }
      end
    end
  end
end
