package util

import (
	"math/rand"
	"time"
)

// Random is random int.
func Random(len int) int {
	rand.Seed(time.Now().UTC().UnixNano())
	return rand.Intn(len)
}
