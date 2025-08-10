import gleam/erlang/process
import gleam/http.{Delete, Get, Post, Put}

pub type Handler(in, out) {
  Handler(method: http.Method, path: List(String), handler: fn(in) -> out)
}

pub fn get(path: List(String), handler: fn(in) -> out) -> Handler(in, out) {
  Handler(method: Get, path: path, handler: handler)
}

pub fn post(path: List(String), handler: fn(in) -> out) -> Handler(in, out) {
  Handler(method: Post, path: path, handler: handler)
}

pub fn put(path: List(String), handler: fn(in) -> out) -> Handler(in, out) {
  Handler(method: Put, path: path, handler: handler)
}

pub fn delete(path: List(String), handler: fn(in) -> out) -> Handler(in, out) {
  Handler(method: Delete, path: path, handler: handler)
}

pub fn spawn(
  handler: Handler(in, out),
  req_path: #(http.Method, List(String)),
  in: in,
  subject: process.Subject(out),
) -> Result(Nil, Nil) {
  case handler {
    Handler(method, path, handler) if req_path == #(method, path) -> {
      process.spawn(fn() {
        let res = handler(in)
        process.send(subject, res)
      })
      Ok(Nil)
    }
    _ -> Error(Nil)
  }
}
