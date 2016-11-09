require 'yaml'

class BotGame

  attr_accessor :game

  DATA_PATH = File.join(File.dirname(__FILE__), 'scores.yml')
  RULES = [
    '------------Rules!-----------',
    "You need guess secret code. This FOUR-digit number(guess) with symbols from 1 to 6",
    "You have #{Codeguessing::Game::MAX_ATTEMPTS} attempt(s) and #{Codeguessing::Game::MAX_HINT} hint(s)",
    "A '+' indicates an exact match: one of the numbers in the guess is the same as one of the numbers in the secret code and in the same position.",
    "A '-' indicates a number match: one of the numbers in the guess is the same as one of the numbers in the secret code but in a different position.",
    "A empty answer means that you nothing guessed",
    "If you want get hint write 'hint'",
    "If you want start game write your guess-number",
    '-----------------------------'
  ]

  def initialize
    @scores = load(DATA_PATH) || []
    @game = Codeguessing::Game.new
  end

  def go(code)
    guess = "Your guess: #{@game.guess(code)}\n"
    case @game.win?
    when true
      "You win!\nYou can save your result with command save"
    when false
      "You loose\nSecret code was #{@game.secret_code}"
    else
      state + guess
    end
  end

  def state
    message = "Attempts: #{@game.attempts} Hint: #{@game.hint_count}\n"
  end

  def load(path)
    YAML.load(File.open(path)) if File.exist?(path)
  end

  def save!(name = 'Anonim')
    return 'You cant save game' unless @game.win?
    score = @game.cur_score(name)
    @scores << score
    File.new(DATA_PATH, 'w') unless File.exist?(DATA_PATH)
    File.open(DATA_PATH, "r+") { |f| f.write(@scores.to_yaml) }
    parse_score(score)
  end

  def scores
    return 'Table of scores is empty' if @scores.empty?
    message = ''
    @scores.each do |score|
      message += parse_score(score)
    end
    message
  end

  def parse_score(score)
    score_msg = [
      '--------------------',
      "#{score[:name]}",
      '--------------------',
      "Attempts: #{score[:attempts]}",
      "Hint: #{score[:hint_count]}",
      "Date: #{Time.at(score[:date]).strftime("%d %B %Y")}\n",
    ].join("\n")
  end
end
