package models

// Config 全ての設定を格納
type Config struct {
	Discord DiscordSetting `toml:"Discord"`
	Mongo   MongoSetting   `toml:"Mongo"`
	Redis   RedisSetting   `toml:"Redis"`
}

// DiscordSetting Discord の設定
type DiscordSetting struct {
	Token    string `toml:"Token"`
	Prefix   string `toml:"Prefix"`
	Playing  string `toml:"Playing"`
	ClientID string `toml:"ClientID"`
}

// MongoSetting MongoDB の設定
type MongoSetting struct {
	Host string `toml:"Host"`
	DB   string `toml:"DB"`
	Port int    `toml:"Port"`
}

// RedisSetting Redis の設定
type RedisSetting struct {
	Host string `toml:"Host"`
	Port int    `toml:"Port"`
}
