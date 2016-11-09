require "codeguessing"
require_relative 'bot_game'
require "telegram/bot"

token = '268384989:AAHxzzJGWQiVw8lDKGg0S8xntboUDVJ_S20'

Telegram::Bot::Client.run(token) do |bot|
  bot_breaker = BotGame.new

  bot.listen do |message|
    question = message.from.first_name

    answers =
      Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: [%w(hint attempts scores), %w(start exit replay)])

    case message.text
    when /start/i
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Let's breake all secret")

    when /^[1-6]{#{Codeguessing::Game::MAX_SIZE}}$/s
      bot.api.send_message(
        chat_id: message.chat.id,
        text: bot_breaker.go(message.text))

    when /replay/i
      bot_breaker = TelegramGame.new
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "New Game\n#{bot_breaker.cur_score}")

    when /hint/i
      hint = bot_breaker.game.hint
      hint_msg = bot_breaker.cur_score + "Hint: #{hint}\n"
      bot.api.send_message(
        chat_id: message.chat.id,
        text: hint_msg)

    when /stop/i
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Bye, #{message.from.first_name}")

    else
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "I don't know what's mean #{message.text}")
    end
  end
end
