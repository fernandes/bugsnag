require "./spec_helper"
require "http/server"

describe Bugsnag do
  describe "metadta filters" do
    it "filters out protected values in query params" do
      io = IO::Memory.new
      request = HTTP::Request.new("GET", "/?foo=bar&password=nobeuno")
      response = HTTP::Server::Response.new(io)
      context = HTTP::Server::Context.new(request, response)
      request = Bugsnag::Request.new(context)
      request.url.should eq("/?foo=bar&password=[FILTERED]")
    end
  end
end
