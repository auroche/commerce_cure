use Mix.Config

config :commerce_cure, CommerceCureTest,
  url: "https://httparrot.herokuapp.com/post",
  username: "HAIYAH",
  password: Enum.map(?a..?z, fn x -> x end) ++ Enum.map(?A..?Z, fn x -> x end) ++ Enum.map(?0..?9, fn x -> x end) |> Enum.take_random(64),
  cert_file: "certs/key.pem"
