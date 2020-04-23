module Bugsnag
  class User
    include JSON::Serializable

    property id : String?
    property name : String?
    property email : String?

    def initialize(@id : String? = nil, @name : String? = nil, @email : String? = nil); end
  end
end
