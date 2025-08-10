import gleam/bytes_tree
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import logging
import mist.{type Connection}
import zerra/entry_server

pub fn main() -> Nil {
  logging.configure()
  logging.set_level(logging.Debug)

  let assert Ok(_) =
    entry_server.new()
    |> entry_server.add_endpoint(#(http.Get, [], hello))
    |> entry_server.start

  process.sleep_forever()
}

fn hello(_req: Request(Connection)) {
  response.new(200)
  |> response.set_body(mist.Bytes(bytes_tree.from_string("Hello!")))
}
