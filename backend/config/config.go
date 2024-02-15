package config

import (
	"encoding/json"
	"fmt"
	"os"
)

var (
	HttpPort	int
	Ssl			SslConfig


	config *ConfigStruct
)

type SslConfig struct {
	Enabled			bool	`json:"Enabled"`
	Certificate		string	`json:"Certificate"`
	PrivateKey		string	`json:"PrivateKey"`
}

type ConfigStruct struct {
	HttpPort	int  		`json:"HttpPort"`
	SslConfig 	SslConfig	`json:"SSL"`
}

func ReadConfig() error {
	fmt.Println("Reading config file...")
	file, error := os.ReadFile("./config.json")

	if error != nil {
		fmt.Println(error.Error())
		return error
	}

	error = json.Unmarshal(file, &config)

	if error != nil {
		fmt.Println(error.Error())
		return error
	}

	HttpPort = config.HttpPort
	Ssl = config.SslConfig

	return nil
}