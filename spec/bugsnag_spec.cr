require "./spec_helper"
require "http/server"

describe Bugsnag do
  describe "metadata filters" do
    it "filters out protected values in query params" do
      request = get_request({
        "foo"      => "bar",
        "password" => "snakesonaplane",
      })
      request.params["foo"].should eq("bar")
      request.params["password"].should eq("[FILTERED]")
    end

    it "filters out protected post param values" do
      request = post_request({
        "username"            => "samjackson",
        "login_form:password" => "snakesonaplane",
      })
      request.post_params.not_nil!["username"].should eq("samjackson")
      request.post_params.not_nil!["login_form:password"].should eq("[FILTERED]")
    end
  end

  describe "release stages" do
    it "sends when release stage matches the BUGSNAG_RELEASE_STAGE environment variable" do
      ENV["BUGSNAG_RELEASE_STAGE"] = "forthehellofit"
      Bugsnag.config { |c| c.release_stage = ["forthehellofit"] }

      context = HTTP::Server::Context.new(
        HTTP::Request.new("GET", "/"),
        HTTP::Server::Response.new(IO::Memory.new))
      exception = Exception.new("WTF?!?")

      Bugsnag.report(context, exception).should eq(nil)
    end

    it "does not send when the release stage does not match" do
      ENV["BUGSNAG_RELEASE_STAGE"] = "popeanope"
      Bugsnag.config { |c| c.release_stage = ["saywhat"] }

      context = HTTP::Server::Context.new(
        HTTP::Request.new("GET", "/"),
        HTTP::Server::Response.new(IO::Memory.new))
      exception = Exception.new("WTF?!?")

      Bugsnag.report(context, exception).should eq("Not in release stage")
    end
  end
end
