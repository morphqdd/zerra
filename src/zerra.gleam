import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/string
import logging
import mist.{type Connection, type ResponseData}
import zerra/entry_server

pub fn main() -> Nil {
  logging.configure()
  logging.set_level(logging.Debug)

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      logging.log(logging.Info, string.inspect(req))
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
    }
    |> entry_server.new
    |> entry_server.start

  process.sleep_forever()
}
