require "codeguessing"
require_relative 'bot_game'
require "telegram/bot"

token = '268384989:AAHxzzJGWQiVw8lDKGg0S8xntboUDVJ_S20'

Telegram::Bot::Client.run(token) do |bot|
  bot_game = BotGame.new

  bot.listen do |message|
    question = message.from.first_name

    markup =
      Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: [%w(hint scores save), ['new game'], ['give up']])

    case message.text
    when /start/i
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "#{message.from.first_name}, wellcome to Codeguessing!\nIf you want to know about the rules enter 'rules' ",
        reply_markup: markup)

    when /^[1-6]{#{Codeguessing::Game::MAX_SIZE}}$/s
      bot.api.send_message(
        chat_id: message.chat.id,
        text: bot_game.go(message.text))

    when /new game/i
      bot_game = BotGame.new
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "#{bot_game.state}\nNew Game")

    when /hint/i
      hint = bot_game.game.hint
      hint_msg = bot_game.state + "Hint: #{hint}\n"
      bot.api.send_message(
        chat_id: message.chat.id,
        text: hint_msg)

    when /rules/i
      bot.api.send_message(
        chat_id: message.chat.id,
        text: BotGame::RULES.join("\n"))

    when /save/i
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "#{bot_game.save!(message.from.first_name)}")
        bot_game = BotGame.new

    when /scores/i
      bot.api.send_message(
      chat_id: message.chat.id,
      text: bot_game.scores)

    when /give up/i
      bot_game = BotGame.new
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Sorry, #{message.from.first_name}, but secret code was #{bot_game.game.secret_code}")

    else
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "I don't know what's mean #{message.text}")
    end
  end
end
