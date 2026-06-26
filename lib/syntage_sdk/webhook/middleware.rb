# frozen_string_literal: true

require 'openssl'
require 'json'

module SyntageSdk
  module Webhook
    class Middleware
      SIGNATURE_HEADER    = 'HTTP_X_SYNTAGE_SIGNATURE'
      EVENT_ENV_KEY       = 'syntage.webhook_event'
      TIMESTAMP_TOLERANCE = 300

      def initialize(app, secret: ENV['SYNTAGE_WEBHOOK_SECRET'])
        @app    = app
        @secret = secret
      end

      def call(env)
        signing_secret = fetch_secret
        raw_body       = read_body env
        header         = env[SIGNATURE_HEADER].to_s

        return unauthorized unless valid_signature? raw_body, header, signing_secret

        payload = parse_json raw_body
        return bad_request unless payload

        env[EVENT_ENV_KEY] = Event.from_payload payload
        @app.call env
      end

      private

      def fetch_secret
        secret = @secret.to_s.strip
        return secret unless secret.empty?

        raise ConfigurationError,
              'Missing Syntage webhook secret. Pass it as ' \
              '`use SyntageSdk::Webhook::Middleware, secret: "..."` ' \
              'or set the SYNTAGE_WEBHOOK_SECRET environment variable.'
      end

      def read_body(env)
        input = env['rack.input']
        body  = input.read
        input.rewind
        body
      end

      def valid_signature?(body, header_value, secret)
        parts                = parse_signature_header header_value
        timestamp, signature = parts.values_at 't', 's'
        return false unless timestamp && signature
        return false unless fresh_timestamp? timestamp

        signed_payload = "#{timestamp}.#{body}"
        expected = OpenSSL::HMAC.hexdigest 'SHA256', secret, signed_payload
        return false if expected.bytesize != signature.bytesize

        OpenSSL.fixed_length_secure_compare expected, signature
      end

      def parse_signature_header(header_value)
        header_value.split(',').each_with_object({}) do |pair, result|
          key, value = pair.split '=', 2
          result[key] = value if key && value
        end
      end

      def fresh_timestamp?(timestamp)
        return false unless timestamp.match?(/\A\d+\z/)

        (Time.now.to_i - timestamp.to_i).abs <= TIMESTAMP_TOLERANCE
      end

      def parse_json(body)
        JSON.parse body
      rescue JSON::ParserError
        nil
      end

      def unauthorized
        [401, { 'Content-Type' => 'application/json' }, ['{"error":"invalid signature"}']]
      end

      def bad_request
        [400, { 'Content-Type' => 'application/json' }, ['{"error":"invalid payload"}']]
      end
    end
  end
end
