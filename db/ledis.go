package db

import (
	"log"

	lediscfg "github.com/ledisdb/ledisdb/config"
	"github.com/ledisdb/ledisdb/ledis"
)

// LDB is LedisDB
var LDB *ledis.DB

func initLedis() {
	cfg := lediscfg.NewConfigDefault()
	cfg.DataDir = "data/ledis"
	l, err := ledis.Open(cfg)
	if err != nil {
		log.Fatal(err)
	}
	LDB, err = l.Select(0)
	if err != nil {
		log.Fatal(err)
	}
}
