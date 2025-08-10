import gleam/bytes_tree
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/option.{type Option, None, Some}
import mist.{type Connection, type ResponseData}
import zerra/entry_server/handler.{type Handler, Handler}

pub type EntryServer(a, b) {
  EntryServer(
    subject: process.Subject(Response(b)),
    address: Option(String),
    port: Option(Int),
    endpoints: List(Handler(Request(a), Response(b))),
  )
}

pub fn new() -> EntryServer(a, b) {
  EntryServer(
    subject: process.new_subject(),
    address: None,
    port: None,
    endpoints: [],
  )
}

pub fn bind(
  server: EntryServer(a, b),
  address: String,
  port: Int,
) -> EntryServer(a, b) {
  EntryServer(
    subject: server.subject,
    address: Some(address),
    port: Some(port),
    endpoints: server.endpoints,
  )
}

pub fn add_endpoint(
  server: EntryServer(a, b),
  endpoint: #(http.Method, List(String), fn(Request(a)) -> Response(b)),
) -> EntryServer(a, b) {
  EntryServer(
    subject: server.subject,
    address: server.address,
    port: server.port,
    endpoints: [
      Handler(handler: endpoint.2, method: endpoint.0, path: endpoint.1),
      ..server.endpoints
    ],
  )
}

pub fn start(server: EntryServer(mist.Connection, mist.ResponseData)) {
  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case resolve_req(server.endpoints, req) {
        Ok(res) -> res
        Error(_) ->
          response.new(404)
          |> response.set_body(mist.Bytes(bytes_tree.new()))
      }
    }
    |> mist.new
    |> mist.bind(server.address |> option.unwrap("localhost"))
    |> mist.port(server.port |> option.unwrap(3000))
    |> mist.start
}

fn resolve_req(
  endpoints: List(Handler(Request(a), Response(b))),
  req: Request(a),
) -> Result(Response(b), Nil) {
  case endpoints {
    [h, ..tl] -> {
      let subject = process.new_subject()
      case
        handler.spawn(
          h,
          #(req.method, request.path_segments(req)),
          req,
          subject,
        )
      {
        Ok(_) -> Ok(process.receive_forever(subject))
        Error(_) -> resolve_req(tl, req)
      }
    }
    [] -> Error(Nil)
  }
}
