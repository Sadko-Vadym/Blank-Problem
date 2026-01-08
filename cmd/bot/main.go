package main

import (
	"log"
	"os"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
)

var (
	// AppVersion is set during build
	AppVersion = "v1.0.0"
)

func main() {
	token := os.Getenv("TELE_TOKEN")
	if token == "" {
		log.Fatal("TELE_TOKEN environment variable is not set")
	}

	bot, err := tgbotapi.NewBotAPI(token)
	if err != nil {
		log.Panic(err)
	}

	bot.Debug = false
	log.Printf("Authorized on account %s", bot.Self.UserName)
	log.Printf("Bot version: %s", AppVersion)

	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	updates := bot.GetUpdatesChan(u)

	for update := range updates {
		if update.Message == nil {
			continue
		}

		log.Printf("[%s] %s", update.Message.From.UserName, update.Message.Text)

		var reply string
		switch update.Message.Text {
		case "/start":
			reply = "Hello! I'm a bot created for DevOps course. Use /help to see available commands."
		case "/help":
			reply = "Available commands:\n/start - Start the bot\n/help - Show this help\n/version - Show bot version"
		case "/version":
			reply = "Bot version: " + AppVersion
		default:
			reply = "You said: " + update.Message.Text
		}

		msg := tgbotapi.NewMessage(update.Message.Chat.ID, reply)
		msg.ReplyToMessageID = update.Message.MessageID

		if _, err := bot.Send(msg); err != nil {
			log.Printf("Error sending message: %v", err)
		}
	}
}

