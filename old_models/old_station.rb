class OldStation < ApplicationRecord
  establish_connection adapter: "mysql2",
    host: "127.0.0.1",
    username: "wayne",
    password: "agem.Data",
    database: "aws"
  self.table_name = "stations"
end
