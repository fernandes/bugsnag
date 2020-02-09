module Bugsnag
  class Config
    property api_key : String
    property name : String
    property version : String
    property url : String
    property release_stage : String
    property metadata_filters : Array(Regex)

    def initialize
      @api_key = ENV["BUGSNAG_API_KEY"]? || ""
      @name = ""
      @version = ""
      @url = ""
      @release_stage = ENV["BUGSNAG_RELEASE_STAGE"]? || "production"
      @metadata_filters = [
        /authorization/i,
        /cookie/i,
        /password/i,
        /secret/i,
      ]
    end
  end
end
