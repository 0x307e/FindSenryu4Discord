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

// GenSenryu is generate senryu service.
func GenSenryu(serverID string) (str string, errArr []error) {
	var (
		s []model.Senryu
		n int = 2
	)
	if errArr = db.DB.Where(&model.Senryu{ServerID: serverID}).Limit(3).Find(&s).GetErrors(); len(errArr) != 0 {
		return "", errArr
	}
	if len(s) == 0 {
		str = "まだ誰も詠んでいません。あなたが先に詠んでください。"
	} else {
		if len(s) < n {
			n = len(s)
		}
		senryu := []string{
			s[util.Random(n)].Kamigo,
			s[util.Random(n)].Nakasichi,
			s[util.Random(n)].Simogo,
		}

		str = fmt.Sprintf("ここで一句\n「%s」", strings.Join(senryu, " "))
	}
	return str, errArr
}
