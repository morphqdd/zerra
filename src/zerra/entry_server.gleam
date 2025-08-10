import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/option.{type Option, None, Some}
import mist

pub type EntryServer(a, b) {
  EntryServer(
    address: Option(String),
    port: Option(Int),
    handler: fn(Request(a)) -> Response(b),
  )
}

pub fn new(handler: fn(Request(a)) -> Response(b)) -> EntryServer(a, b) {
  EntryServer(handler, address: None, port: None)
}

pub fn bind(
  server: EntryServer(a, b),
  address: String,
  port: Int,
) -> EntryServer(a, b) {
  EntryServer(handler: server.handler, address: Some(address), port: Some(port))
}

pub fn start(server: EntryServer(mist.Connection, mist.ResponseData)) {
  let assert Ok(_) =
    mist.new(server.handler)
    |> mist.bind(server.address |> option.unwrap("localhost"))
    |> mist.port(server.port |> option.unwrap(3000))
    |> mist.start
}
