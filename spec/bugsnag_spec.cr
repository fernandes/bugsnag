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
end
