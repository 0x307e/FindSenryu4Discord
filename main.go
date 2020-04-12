package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/BurntSushi/toml"
	"github.com/bwmarrin/discordgo"
	"github.com/makotia/FindSenryu4Discord/models"
	"github.com/mattn/go-haiku"
)

func main() {
	var (
		err    error
		config models.Config
	)

	log.SetFlags(log.Lshortfile)
	if _, err = toml.DecodeFile("config.toml", &config); err != nil {
		log.Fatal(err)
	}
	dg, err := discordgo.New("Bot " + config.Discord.Token)
	if err != nil {
		log.Fatal("error creating Discord session")
	}
	dg.AddHandler(messageCreate)
	err = dg.Open()
	if err != nil {
		fmt.Println(err)
		log.Fatal("error opening connection")
	}

	dg.UpdateStatus(1, config.Discord.Playing)

	fmt.Println("Bot is now running.  Press CTRL-C to exit.")
	sc := make(chan os.Signal, 1)
	signal.Notify(sc, syscall.SIGINT, syscall.SIGTERM, os.Interrupt, os.Kill)
	<-sc

	dg.Close()
}

func messageCreate(s *discordgo.Session, m *discordgo.MessageCreate) {
	if m.Author.ID != s.State.User.ID {
		h := haiku.Find(m.Content, []int{5, 7, 5})
		if len(h) != 0 {
			fmt.Println(strings.Join(h, " "))
			s.ChannelMessageSend(m.ChannelID, fmt.Sprintf("<@%s> 川柳を検出しました！\n「%s」", m.Author.ID, strings.Join(h, " ")))
		}
	}
}
