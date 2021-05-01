package service

import (
	"fmt"
	"math/rand"
	"time"

	"github.com/makotia/FindSenryu4Discord/db"
	"github.com/makotia/FindSenryu4Discord/model"
)

// CreateSenryu is create senryu service.
func CreateSenryu(s model.Senryu) (model.Senryu, []error) {
	if errArr := db.DB.Create(&s).GetErrors(); len(errArr) != 0 {
		return s, errArr
	}
	if _, err := db.LDB.ZIncrBy([]byte(s.ServerID), 1, []byte(s.AuthorID)); err != nil {
		return s, []error{err}
	}
	return s, nil
}

// GetLastSenryu is get last senryu service.
func GetLastSenryu(serverID string, userID string) (str string, errArr []error) {
	s := model.Senryu{}
	if errArr = db.DB.Where(&model.Senryu{ServerID: serverID}).Last(&s).GetErrors(); len(errArr) != 0 {
		return "", errArr
	}
	if userID == s.AuthorID {
		str = "お前"
	} else {
		str = fmt.Sprintf("<@%s> ", s.AuthorID)
	}
	str += fmt.Sprintf("が「%s %s %s」って詠んだのが最後やぞ", s.Kamigo, s.Nakasichi, s.Simogo)
	return str, nil
}

// GetThreeRandomSenryus is generate senryu service.
func GetThreeRandomSenryus(serverID string) (senryus []model.Senryu, errArr []error) {
	var (
		s []model.Senryu
		n int
	)
	if errArr = db.DB.Where(&model.Senryu{ServerID: serverID}).Find(&s).GetErrors(); len(errArr) != 0 {
		return []model.Senryu{}, errArr
	}
	if len(s) == 0 {
		return []model.Senryu{}, errArr
	} else {
		n = len(s)
		rand.Seed(time.Now().UnixNano())
		return []model.Senryu{
			s[rand.Intn(n)],
			s[rand.Intn(n)],
			s[rand.Intn(n)],
		}, errArr
	}
}
