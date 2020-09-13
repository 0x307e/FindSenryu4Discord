package util

import (
	"math/rand"
	"time"
)

// Shuffle is shuffle int slice.
func Shuffle(n int) []int {
	slice := make([]int, n)
	rand.Seed(time.Now().UnixNano())

	for i := 0; i < len(slice); i++ {
		slice[i] = i
	}

	rand.Shuffle(len(slice), func(i, j int) { slice[i], slice[j] = slice[j], slice[i] })
	return slice
}
