package db

import (
	"github.com/jinzhu/gorm"
	"github.com/makotia/FindSenryu4Discord/model"

	// SQLite3 driver for Gorm
	_ "github.com/mattn/go-sqlite3"
)

var (
	// DB is GormDB
	DB  *gorm.DB
	err error
)

// Init is initialize dbs from main function
func Init() {
	initDB()
	initLedis()
}

func initDB() {
	DB, err = gorm.Open("sqlite3", "data/senryu.db")
	if err != nil {
		panic(err)
	}
	DB.AutoMigrate(&model.Senryu{})
}

// Close is closing db
func Close() {
	if err := DB.Close(); err != nil {
		panic(err)
	}
}
