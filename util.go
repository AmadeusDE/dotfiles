package main

import (
	"encoding/json"
	"log"
	"os"
)

var (
	tokens Tokens
)

type Tokens struct {
	GeminiToken string
}

func loadTokens() {
	homeDir, err := os.UserHomeDir()
	filePath := homeDir + "/.dotfiles/tokens.json"
	data, err := os.ReadFile(filePath)
	eror("Error reading JSON file:", err)

	err = json.Unmarshal(data, &tokens)
	eror("Error unmarshaling JSON:", err)
}

func eror(str string, err error) bool {
	berr := err != nil
	if berr {
		log.Fatalf(str+": %v", err)
	}
	return berr
}
