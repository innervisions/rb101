INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                 [1, 4, 7], [2, 5, 8], [3, 6, 9],
                 [1, 5, 9], [3, 5, 7]]
FIRST_PLAYER = 'choose' # 'player', 'computer', or 'choose'
WINS_REQUIRED = 3

def prompt(msg)
  puts "=> #{msg}"
end

def clear_screen
  system('clear') || system('cls')
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
  puts "You're an #{PLAYER_MARKER}. Computer is an #{COMPUTER_MARKER}."
  puts
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts
end
# rubocop:enable Metrics/AbcSize

def display_scores(round, scores)
  clear_screen
  puts "Round #{round}"
  puts '*' * 10
  puts "Player: #{scores['Player']} "
  puts "Computer: #{scores['Computer']}"
  puts "Win #{WINS_REQUIRED} rounds to win the match."
  puts '-' * 40
end

def initialize_board
  (1..9).each_with_object({}) { |num, hsh| hsh[num] = INITIAL_MARKER }
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def joinor(arr, punctuation = ', ', conjunction = 'or')
  case arr.size
  when 1 then arr[0].to_s
  when 2 then "#{arr[0]} #{conjunction} #{arr[1]}"
  else
    arr[0..-2].join(punctuation) + "#{punctuation}#{conjunction} #{arr[-1]}"
  end
end

def find_critical_square_in_line(line, board, marker)
  if board.values_at(*line).count(marker) == 2
    board.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  end
end

def find_critical_square(brd, marker)
  square = nil
  WINNING_LINES.each do |line|
    square = find_critical_square_in_line(line, brd, marker)
    break if square
  end
  square
end

def critical_square(brd)
  square = find_critical_square(brd, COMPUTER_MARKER) # offensive
  square ||= find_critical_square(brd, PLAYER_MARKER) # defensive
  square
end

def player_places_piece!(brd)
  square = nil
  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}):"
    square = gets.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, That's not a valid choice."
  end
  brd[square] = PLAYER_MARKER
end

def computer_places_piece!(brd)
  square = critical_square(brd)
  square ||= empty_squares(brd).include?(5) ? 5 : empty_squares(brd).sample
  brd[square] = COMPUTER_MARKER
end

def place_piece!(brd, current_player)
  if current_player == 'Player'
    player_places_piece!(brd)
  else
    computer_places_piece!(brd)
  end
end

def alternate_player(current_player)
  return 'Computer' if current_player == 'Player'
  'Player'
end

def choose_first_player
  input = nil
  loop do
    prompt "Who would you like to go first?\n(P)layer, (C)omputer, or (R)andom"
    input = gets.chomp.downcase
    unless input.empty?
      return 'Player' if 'player'.start_with?(input)
      return 'Computer' if 'computer'.start_with?(input)
      return ['Computer', 'Player'].sample if 'random'.start_with?(input)
    end
    prompt "That's not a valid choice."
  end
end

def first_player
  return 'Player' if FIRST_PLAYER.downcase == 'player'
  return 'Computer' if FIRST_PLAYER.downcase == 'computer'
  choose_first_player
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    return 'Player' if line.all? { |el| brd[el] == PLAYER_MARKER }
    return 'Computer' if line.all? { |el| brd[el] == COMPUTER_MARKER }
  end
  nil
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def determine_winner(board, scores)
  if someone_won?(board)
    winner = detect_winner(board)
    prompt "#{winner} won!"
    scores[winner] += 1
  else
    prompt "It's a tie!"
  end
end

def play_round(round, scores)
  board = initialize_board
  display_scores(round, scores)
  current_player = first_player
  loop do
    display_scores(round, scores)
    display_board(board)
    place_piece!(board, current_player)
    break if someone_won?(board) || board_full?(board)
    current_player = alternate_player(current_player)
  end

  display_scores(round, scores)
  display_board(board)
  determine_winner(board, scores)
  prompt 'Press ENTER to continue.'
  gets
end

def play_match
  scores = { 'Player' => 0, 'Computer' => 0 }
  round = 1
  loop do
    play_round(round, scores)
    break if scores.values.include?(WINS_REQUIRED)
    round += 1
  end
  prompt "Player has won #{scores['Player']}. " \
        "Computer has won #{scores['Computer']}."
  prompt "#{scores.key(WINS_REQUIRED)} has won the match!"
end

def play_again?
  loop do
    prompt 'Would you like to play again? (y/n):'
    input = gets.chomp.downcase
    return true if input.start_with?('y')
    return false if input.start_with?('n')
  end
end
# MAIN ###################
loop do
  play_match
  break unless play_again?
end
prompt 'Thank you for playing Tic Tac Toe!'
