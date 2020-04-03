require "spec"
require "../src/bugsnag"

def make_request(request : HTTP::Request)
  Bugsnag::Request.new(
    HTTP::Server::Context.new(
      request,
      HTTP::Server::Response.new(IO::Memory.new)
    )
  )
end

def get_request(query_params)
  make_request(
    HTTP::Request.new(
      "GET",
      "/?" + HTTP::Params.encode(query_params)
    )
  )
end

def post_request(post_params, path = "/")
  make_request(
    HTTP::Request.new(
      "POST",
      path,
      headers: HTTP::Headers{"Content-Type" => "application/x-www-formy-urlencoded"},
      body: HTTP::Params.encode(post_params)
    )
  )
end
