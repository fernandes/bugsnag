require "colorize"
require "json"
require "./bugsnag/*"

module Bugsnag
  @@config = Config.new

  def self.config
    yield @@config
  end

  def self.config : Config
    @@config
  end

  def self.report(context : HTTP::Server::Context, exception : ::Exception) : Nil
    event = Event.new(context, exception)
    yield event
    report(context, exception, event)
  end

  def self.report(context : HTTP::Server::Context, exception : ::Exception) : Nil
    report(context, exception) { |event| }
  end

  def self.report(context : HTTP::Server::Context, exception : ::Exception, event : Event) : Nil
    return "Not in release stage" unless @@config.release_stage

    begin
      notifier = Notifier.new(config.name, config.version, config.url)
      report = Report.new(config.api_key, notifier, [event])

      spawn {
        begin
          headers = HTTP::Headers.new
          headers["Content-Type"] = "application/json"
          HTTP::Client.post("http://notify.bugsnag.com", headers, report.to_json)
          puts "Report sent to bugsnag!".colorize(:red)
        rescue ex
          puts "Error sending report to bugsnag! : #{ex}".colorize(:red)
        end
      }
    rescue ex
      puts "Error in bugsnag-crystal! : #{ex}".colorize(:red)
    end
  end
end
