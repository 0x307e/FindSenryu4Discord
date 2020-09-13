package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/makotia/FindSenryu4Discord/db"
	"github.com/makotia/FindSenryu4Discord/model"
	"github.com/makotia/FindSenryu4Discord/service"

	"github.com/bwmarrin/discordgo"
	"github.com/makotia/FindSenryu4Discord/config"
	"github.com/mattn/go-haiku"
)

func main() {
	var (
		err error
	)

	log.SetFlags(log.Lshortfile)
	conf := config.GetConf()
	dg, err := discordgo.New("Bot " + conf.Discord.Token)
	if err != nil {
		log.Fatal("error creating Discord session")
	}
	dg.AddHandler(messageCreate)
	err = dg.Open()
	if err != nil {
		fmt.Println(err)
		log.Fatal("error opening connection")
	}

	db.Init()

	dg.UpdateStatus(1, conf.Discord.Playing)

	fmt.Println("Bot is now running.  Press CTRL-C to exit.")
	sc := make(chan os.Signal, 1)
	signal.Notify(sc, syscall.SIGINT, syscall.SIGTERM, os.Interrupt, os.Kill)
	<-sc

	dg.Close()
}

func messageCreate(s *discordgo.Session, m *discordgo.MessageCreate) {
	var (
		senryu string
		errArr []error
	)

	prefix := config.GetPrefix()
	cmd := strings.Replace(m.Content, prefix, "", 1)
	muted := service.IsMute(m.ChannelID)

	if strings.HasPrefix(cmd, "mute") {
		if err := service.ToMute(m.ChannelID); err != nil {
			s.MessageReactionAdd(m.ChannelID, m.ID, "❌")
		}
		s.MessageReactionAdd(m.ChannelID, m.ID, "✅")
	}

	if strings.HasPrefix(cmd, "unmute") {
		if err := service.ToUnMute(m.ChannelID); err != nil {
			s.MessageReactionAdd(m.ChannelID, m.ID, "❌")
		}
		s.MessageReactionAdd(m.ChannelID, m.ID, "✅")
	}

	switch m.Content {
	case "詠め":
		if senryu, errArr = service.GenSenryu(m.GuildID); len(errArr) != 0 {
			s.MessageReactionAdd(m.ChannelID, m.ID, "❌")
		}
		s.ChannelMessageSend(m.ChannelID, senryu)
	case "詠むな":
		if senryu, errArr = service.GetLastSenryu(m.GuildID, m.Author.ID); len(errArr) != 0 {
			s.MessageReactionAdd(m.ChannelID, m.ID, "❌")
		}
		s.ChannelMessageSend(m.ChannelID, senryu)
	}

	if !muted {
		if m.Author.ID != s.State.User.ID {
			h := haiku.Find(m.Content, []int{5, 7, 5})
			if len(h) != 0 {
				senryu := strings.Split(h[0], " ")
				service.CreateSenryu(
					model.Senryu{
						ServerID:  m.GuildID,
						AuthorID:  m.Author.ID,
						Kamigo:    senryu[0],
						Nakasichi: senryu[1],
						Simogo:    senryu[2],
					},
				)
				s.ChannelMessageSend(m.ChannelID, fmt.Sprintf("<@%s> 川柳を検出しました！\n「%s」", m.Author.ID, h[0]))
			}
		}
	}
}
