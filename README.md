# Syntage SDK

Ruby SDK for the [Syntage](https://api.syntage.com) API.

It centralizes configuration (authentication and environment) in a single place,
so the client application sets it up once and every request reuses it. It also
exposes the metadata of each response (request identifier and rate limit status)
to make traceability and usage control easy.

## Requirements

- Ruby >= 3.4.0

## Installation

The code lives as a gem under `lib/`. While it is not published yet, you can
point to it from your `Gemfile`:

```ruby
gem 'syntage_sdk', path: 'path/to/syntage_sdk'
```

## Configuration

Configuration is global: it is defined once when the application boots.

```ruby
SyntageSdk.configure do |config|
  config.api_key     = ENV.fetch('SYNTAGE_API_KEY')
  config.environment = :development # :production by default
end
```

| Option         | Description                                            | Default                         |
| -------------- | ----------------------------------------------------- | ------------------------------- |
| `api_key`      | Key sent in the `X-API-Key` header                    | `ENV['SYNTAGE_API_KEY']`        |
| `environment`  | Active environment: `:development` or `:production`   | `:production` (or `SYNTAGE_ENV`)|
| `base_url`     | Base URL; overrides the environment one when assigned | Based on the environment        |
| `timeout`      | Read timeout in seconds                               | `30`                            |
| `open_timeout` | Connection timeout in seconds                          | `10`                            |

The environment determines the base URL:

| Environment    | Base URL                          |
| -------------- | --------------------------------- |
| `:development` | `https://api.sandbox.syntage.com` |
| `:production`  | `https://api.syntage.com`         |

Accessing the configuration and the authentication headers:

```ruby
SyntageSdk.config.base_url # => "https://api.sandbox.syntage.com"
SyntageSdk.config.headers
# => {
#      "X-API-Key"    => "your-api-key",
#      "Content-Type" => "application/json",
#      "Accept"       => "application/json"
#    }
```

If you request the `headers` without having configured an `api_key`, a
`SyntageSdk::ConfigurationError` is raised with a clear message, instead of
failing later with a `401`.

## Response metadata

From a response's headers you can read its identifier and rate limit status.

### Request ID

Each API request has an identifier in the `X-Request-ID` header. This is the
value to share with support to resolve issues with a specific endpoint.

### Rate limit

The API reports your quota in the `X-RateLimit-Limit`, `X-RateLimit-Remaining`
and `X-RateLimit-Reset` headers (the last one in UTC epoch seconds).

```ruby
metadata = SyntageSdk::ResponseMetadata.from_headers(response_headers)

metadata.request_id           # => "f242e9e0-c1ba-4bbe-ba64-4966c702b5d2"

rate_limit = metadata.rate_limit
rate_limit.limit              # => 60   (maximum allowed)
rate_limit.remaining          # => 56   (requests left)
rate_limit.reset              # => 1606678044 (reset, UTC epoch)
rate_limit.reset_at           # => 2020-11-29 19:27:24 UTC
rate_limit.exceeded?          # => false
```

## Errors

| Error                            | When                                                    |
| -------------------------------- | ------------------------------------------------------- |
| `SyntageSdk::Error`              | Base class for every SDK error                          |
| `SyntageSdk::ConfigurationError` | Invalid configuration (e.g. missing `api_key`)          |
| `SyntageSdk::ApiError`           | API failure; exposes `request_id` for traceability      |
| `SyntageSdk::RateLimitError`     | `429` response; also exposes `rate_limit`               |

Both `ApiError` and `RateLimitError` carry the response metadata:

```ruby
begin
  # ... API call ...
rescue SyntageSdk::RateLimitError => error
  error.request_id          # to report to support
  error.rate_limit.reset_at # when the quota frees up to retry
end
```

## Console

The gem ships with a console that has the SDK already loaded:

```bash
bin/console
```

```ruby
SyntageSdk.configure { |c| c.api_key = 'sk_test_123' }
SyntageSdk.config.base_url
```

## Development

CI validates three things:

```bash
bin/rubocop        # style
bin/reek lib       # code smells
bundle exec rspec  # tests with coverage (min. 95% line / 90% branch)
```
