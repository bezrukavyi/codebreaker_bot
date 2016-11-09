require "codeguessing"
require 'telegram_bot'

class Game < Codeguessing::Game
end
@game = Game.new

bot = TelegramBot.new(token: '###')
bot.get_updates(fail_silently: true) do |message|
  puts "@#{message.from.username}: #{message.text}"
  command = message.get_command_for(bot)

  message.reply do |reply|
    case command
    when /start/i
      game_message = "Attempts: #{@game.attempts} Hint: #{@game.hint_count}\nWrite your guess"
      reply.text = game_message
    when /^[1-6]{#{Game::MAX_SIZE}}$/s
      answer = @game.guess(command)
      game_message =
        case @game.win?
        when true
          ["You win"]
        when false
          ["Game over"]
        else
          [
            "Attempts: #{@game.attempts} Hint: #{@game.hint_count}\nWrite your guess",
            "Answer: #{answer}"
          ]
        end
      reply.text = game_message.join("\n")
    when /hint/i
      reply.text = @game.hint
    when /restart/i
      @game = Game.new
    end
    puts "sending #{reply.text.inspect} to @#{message.from.username}"
    reply.send_with(bot)
  end
end
