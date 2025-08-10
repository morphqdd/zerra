import gleam/bytes_tree
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import zerra/entry_server

pub fn entry_server_start_test() {
  let assert Ok(_) =
    fn(_req: Request(Connection)) -> Response(ResponseData) {
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
    }
    |> entry_server.new
    |> entry_server.start
}
