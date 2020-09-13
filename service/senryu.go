package service

import (
	"fmt"
	"strings"

	"github.com/makotia/FindSenryu4Discord/db"
	"github.com/makotia/FindSenryu4Discord/model"
	"github.com/makotia/FindSenryu4Discord/util"
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
		str = fmt.Sprintf("<@%s> お前", s.AuthorID)
	} else {
		str = fmt.Sprintf("<@%s> ", s.AuthorID)
	}
	str += fmt.Sprintf("が「%s %s %s」って詠んだのが最後やぞ", s.Kamigo, s.Nakasichi, s.Simogo)
	return str, nil
}

// GenSenryu is generate senryu service.
func GenSenryu(serverID string) (str string, errArr []error) {
	var (
		s []model.Senryu
		n int
	)
	if errArr = db.DB.Where(&model.Senryu{ServerID: serverID}).Find(&s).GetErrors(); len(errArr) != 0 {
		return "", errArr
	}
	if len(s) == 0 {
		str = "まだ誰も詠んでいません。あなたが先に詠んでください。"
	} else {
		n = len(s)
		arr := util.Shuffle(n)
		senryu := []string{
			s[arr[0]].Kamigo,
			s[arr[1]].Nakasichi,
			s[arr[2]].Simogo,
		}

		str = fmt.Sprintf("ここで一句\n「%s」", strings.Join(senryu, " "))
	}
	return str, errArr
}
