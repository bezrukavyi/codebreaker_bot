require "codeguessing"
require_relative 'bot_game'
require "telegram/bot"

token = '268384989:AAHxzzJGWQiVw8lDKGg0S8xntboUDVJ_S20'

Telegram::Bot::Client.run(token) do |bot|
  bot_game = Botguessing.new

  bot.listen do |message|
    question = message.from.first_name

    markup =
      Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: [%w(hint scores save rules), ['new game'], ['give up']])

    case message.text
    when /start/i
      wellcome = [
        "#{message.from.first_name}, wellcome to Codeguessing!",
        "So, if you ready guess, click on keyboard 'new game'",
        "If you want to know about the rules click to 'rules'"
      ]
      bot.api.send_message(
        chat_id: message.chat.id,
        text: wellcome.join("\n"),
        reply_markup: markup)

    when /^[1-6]{#{Codeguessing::Game::MAX_SIZE}}$/s
      bot.api.send_message(
        chat_id: message.chat.id,
        text: bot_game.go(message.text))

    when /new game/i
      bot_game = Botguessing.new
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Bot maked secret code.\n#{bot_game.state}")

    when /hint/i
      hint = bot_game.game.hint
      hint_msg = bot_game.state + "Hint: #{hint}\n"
      bot.api.send_message(
        chat_id: message.chat.id,
        text: hint_msg)

    when /rules/i
      bot.api.send_message(
        chat_id: message.chat.id,
        text: Botguessing::RULES.join("\n"))

    when /save/i
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "#{bot_game.save!(message.from.first_name)}")
        bot_game = Botguessing.new

    when /scores/i
      bot.api.send_message(
      chat_id: message.chat.id,
      text: bot_game.scores)

    when /give up/i
      bot_game = Botguessing.new
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Sorry, #{message.from.first_name}, but secret code was #{bot_game.game.secret_code}")

    else
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Incorrect data #{message.text}. Read again rules")
    end
  end
end
