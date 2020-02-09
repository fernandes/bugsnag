module Bugsnag
  class Request
    include JSON::Serializable

    @[JSON::Field(key: "clientIp")]
    property client_ip : String?
    property headers : Hash(String, String)?
    @[JSON::Field(key: "httpMethod")]
    property http_method : String?
    property url : String?
    property referer : String?

    def initialize(context : HTTP::Server::Context)
      @client_ip = remote_ip(context.request)
      @http_method = context.request.method
      @url = context.request.path
      set_headers(context)
    end

    def set_headers(context)
      new_headers = Hash(String, String).new
      request_headers = context.request.headers.to_h
      request_headers.keys.each do |key|
        new_headers[key] = request_headers[key].join(" ")
      end
      @headers = new_headers
    end

    private def remote_ip(request) : String
      ip = request.headers["HTTP_X_FORWARDED_FOR"]? ||
           request.headers["X_FORWARDED_FOR"]? ||
           request.headers["REMOTE_ADDR"]? ||
           request.headers["X-Real-IP"]? ||
           request.headers["HTTP_CLIENT_IP"]? ||
           request.headers["HTTP_X_FORWARDED"]? ||
           request.headers["HTTP_X_CLUSTER_CLIENT_IP"]? ||
           request.remote_address ||
           "127.0.0.1"
      ip.split(',').first.strip
    end
  end
end
