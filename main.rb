require "codeguessing"
require_relative 'bot_game'
require "telegram/bot"

token = '268384989:AAHxzzJGWQiVw8lDKGg0S8xntboUDVJ_S20'

Telegram::Bot::Client.run(token) do |bot|
  bots = {}
  bot.listen do |message|
    message_id = message.chat.id
    bots[message_id] ||= Botguessing.new

    question = message.from.first_name
    markup =
      Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: [%w(hint scores save rules), ['new game'], ['give up']])


    case message.text
    when /start/i
      bots[message_id] = Botguessing.new
      wellcome = [
        "#{message.from.first_name}, wellcome to Codeguessing!",
        "So, if you ready guess, click on keyboard 'new game'",
        "If you want to know about the rules click to 'rules'"
      ]
      bot.api.send_message(
        chat_id: message_id,
        text: wellcome.join("\n"),
        reply_markup: markup)

    when /^[1-6]{#{Codeguessing::Game::MAX_SIZE}}$/s
      bot.api.send_message(
        chat_id: message_id,
        text: bots[message_id].go(message.text))

    when /new game/i
      bots[message_id] = Botguessing.new
      bot.api.send_message(
        chat_id: message_id,
        text: "Bot maked secret code.\nLet's guess!\n#{bots[message_id].state}")

    when /hint/i
      hint = bots[message_id].game.hint
      hint_msg = bots[message_id].state + "Hint: #{hint}\n"
      bot.api.send_message(
        chat_id: message_id,
        text: hint_msg)

    when /rules/i
      bot.api.send_message(
        chat_id: message_id,
        text: Botguessing::RULES.join("\n"))

    when /save/i
      bot.api.send_message(
        chat_id: message_id,
        text: "#{bots[message_id].save!(message.from.first_name)}")
        bots[message_id] = Botguessing.new

    when /scores/i
      bot.api.send_message(
      chat_id: message_id,
      text: bots[message_id].scores)

    when /give up/i
      bots[message_id] = Botguessing.new
      bot.api.send_message(
        chat_id: message_id,
        text: "Sorry, #{message.from.first_name}, but secret code was #{bots[message_id].game.secret_code}")

    else
      bot.api.send_message(
        chat_id: message_id,
        text: "Incorrect data #{message.text}. Read again rules")
    end
  end
end
