module GrapeLogging
  module Formatters
    class Datadog
      def call(severity, datetime, _, data)
        {
          date: datetime.iso8601,
          severity: severity
        }.merge!(format(data)).to_json
      end

      private

      def format(data)
        if data.is_a?(String)
          {message: data}
        elsif data.is_a?(Exception)
          format_exception(data)
        elsif data.is_a?(Hash)
          format_datadog(data)
        end
      end

      def format_datadog(data)
        formatted_hash = {}
        formatted_hash[:network] = {client: { ip: data.delete(:ip) } }
        formatted_hash[:usr] = {id: data.delete(:user_id), name: data.delete(:name), email: data.delete(:email) }
        formatted_hash[:http] = { url: data.delete(:url), useragent: data.delete(:ua), method: data.delete(:method), status_code: data.delete(:status), url_details: {path: data.delete(:path), params: data.delete(:params) } }
        formatted_hash
      end

      def format_exception(exception)
        {
          error: {
            message: exception.message,
            stack: exception.backtrace.take(5).join("\n"),
            kind: exception.class
          }
        }
      end
    end
  end
end