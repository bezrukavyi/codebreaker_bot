class BotGame

  attr_accessor :game

  def initialize
    @game = Codeguessing::Game.new
  end

  def go(code)
    guess = "Your guess: #{@game.guess(code)}\n"
    case @game.win?
    when true
      "You win!"
    when false
      "You loose"
    else
      cur_score + guess
    end
  end

  def cur_score
    message = "Attempts: #{@game.attempts} Hint: #{@game.hint_count}\n"
  end

end
