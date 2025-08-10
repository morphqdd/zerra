import zerra/entry_server

pub fn entry_server_start_test() {
  let assert Ok(_) = 
    entry_server.new()
    |> entry_server.start
}
