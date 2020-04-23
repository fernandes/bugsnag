module Bugsnag
  class Request
    include JSON::Serializable

    @[JSON::Field(key: "clientIp")]
    property client_ip : String?
    property headers : Hash(String, String)?
    @[JSON::Field(key: "httpMethod")]
    property http_method : String?
    property url : String?
    property params : Hash(String, String)
    @[JSON::Field(key: "postParams")]
    property post_params : Hash(String, String)?
    property referer : String?

    def initialize(context : HTTP::Server::Context)
      @client_ip = remote_ip(context.request)
      @http_method = context.request.method
      @url = set_url(context.request)
      @params = filtered_query_params(context.request.query_params).to_h
      @referer = set_referer(context.request)
      set_post_params(context)
      set_headers(context)
    end

    private def set_url(request)
      url = "#{request.host}#{request.path}"
      unless request.query_params.empty?
        url += "?" + filtered_query_params(request.query_params).to_s
      end
      url
    end

    private def set_headers(context)
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

    private def filtered_query_params(query_params) : HTTP::Params
      HTTP::Params.new.tap do |filtered_params|
        query_params.each do |name, value|
          v = if filter_query_param?(name)
                "[FILTERED]"
              else
                value
              end
          filtered_params.add(name, v)
        end
      end
    end

    private def set_post_params(context)
      return if context.request.body.nil?

      new_params = Hash(String, String).new
      HTTP::Params.parse(context.request.body.to_s).each do |key, value|
        new_params[key] = if filter_query_param?(key)
                            "[FILTERED]"
                          else
                            value
                          end
      end
      @post_params = new_params
    end

    private def filter_query_param?(name)
      Bugsnag.config.metadata_filters.any? do |filter|
        case filter
        when Regex
          filter =~ name
        when String
          name.include?(filter)
        end
      end
    end

    private def set_referer(request) : String?
      request.headers["Referer"]?
    end
  end
end
