# Three classes: Player, Game, GameBoard, and Space
# CapitalCase for classes and methods, snake_case for methods and variables

# "Player" objects take in a hash with "name" and "team" fields
class Player
  attr_reader :name, :team

  def initialize(name, team)
    @name = name
    @team = team
  end

  def to_s
    "#{name} (#{team}'s)"
  end
end

# "Space" objects store a space's state - played or unplayed
class Space
  attr_accessor :value

  def initialize(value = ' ')
    @value = value
  end

  def open?
    value == ' '
  end

  def to_s
    value
  end
end

# "Gameboard" objects store the 3x3 grid and can check for end-game scenarios
class GameBoard
  attr_reader :grid

  def initialize(grid = empty_grid)
    @grid = grid
  end

  def get_space(row, column)
    grid[row][column]
  end

  def set_space(row, column, team)
    grid[row][column].value = team
  end

  def game_over
    return :winner if winner?
    return :draw if draw?

    false
  end

  def to_s
    grid.map { |e| e.join(' | ') }.join("\n--+---+--\n")
  end

  private

  def empty_grid
    Array.new(3) { Array.new(3) { Space.new } }
  end

  def position_values(position)
    position.map(&:value)
  end

  def winning_positions
    grid + grid.transpose + diagonals
  end

  def diagonals
    [[grid[0][0], grid[1][1], grid[2][2]], [grid[0][2], grid[1][1], grid[2][0]]]
  end

  def winner?
    winning_positions.each do |position|
      next if position_values(position).any_blank?
      return true if position_values(position).all_same?
    end
    false
  end

  def draw?
    position_values(grid.flatten).none_blank?
  end
end

# Monkey patching the array class
class Array
  def all_same?
    all? { |e| e == self[0] }
  end

  def any_blank?
    any? { |e| e.to_s.strip.empty? }
  end

  def none_blank?
    !any_blank?
  end
end

# "Game" objects store instances of games, including players and the board, and
# execute gameplay. Accepts an array of two players and a game board
class Game
  attr_reader :players, :board, :current_player, :other_player

  def initialize(players, board = GameBoard.new)
    @players = players
    @board = board
    @current_player, @other_player = players.shuffle
  end

  def play
    puts "Welcome to Tic-Tac-Toe, #{current_player} and #{other_player}!"
    puts 'Here is a guide to the game board spaces:'
    puts "\n#{GameBoard.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])}\n\n"
    puts "#{current_player}, you go first."

    loop do
      make_move(current_player)
      puts "\n#{board}\n\n"
      break if board.game_over

      switch_players
    end

    if board.game_over == :winner
      puts "Congratulations, #{current_player}, you win!"
    else
      puts "It's a draw!"
    end
  end

  private

  def make_move(player)
    selection = get_selection(player)
    board.set_space(row(selection), column(selection), current_player.team)
  end

  def get_selection(player)
    loop do
      print "#{player}, select a space: "
      selection = gets.to_i
      return selection if valid?(selection)

      puts "Sorry, #{selection} is unavailable."
    end
  end

  def valid?(i)
    (i.positive? && i < 10) && board.get_space(row(i), column(i)).open?
  end

  def row(i)
    (i / 3.0).ceil - 1
  end

  def column(i)
    (i + 2) % 3
  end

  def switch_players
    # rubocop: disable Style/ParallelAssignment
    @current_player, @other_player = other_player, current_player
    # rubocop: enable Style/ParallelAssignment
  end
end

players = [Player.new('Adam', 'X'), Player.new('Tom', 'O')]
Game.new(players).play
