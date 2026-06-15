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

## Making requests

The SDK ships an HTTP client (backed by HTTParty) that reuses the global
configuration. It serializes JSON bodies, parses JSON responses and turns API
failures into exceptions.

```ruby
client = SyntageSdk.client

response = client.get('entities', query: { page: 1 })
response.body        # parsed JSON
response.status      # 200
response.request_id  # value of X-Request-ID
response.rate_limit  # SyntageSdk::RateLimit

client.post('entities', body: { name: 'Acme', type: 'company' })
```

## Resources

On top of the raw client, the SDK exposes resource objects that map domain
actions to endpoints, so the calling app does not build paths or bodies by hand.

### Entities

Register a taxpayer (`company` or `person`) and, optionally, the datasources to
extract for it.

```ruby
response = SyntageSdk.entities.create(
  name: 'Acme SA de CV',
  type: 'company',
  datasources: [{ name: 'sat' }], # optional
  rfc: 'XAXX010101000'            # optional
)

response.status      # 201
response.body['id']  # the created entity id
```

`name` and `type` are required keyword arguments: omitting them raises an
`ArgumentError` before any request is made. `rfc` and `datasources` are optional
and only sent when provided. If `rfc` is omitted, extractions that need it stay
in a waiting state until it is set.

The valid `datasources` identifiers are not listed in the API reference; they are
passed through as-is and validated by the API (a `400` comes back as a
`SyntageSdk::ValidationError` with the details). `sat` is one known valid value.

### Credentials

Register SAT credentials for a taxpayer so the API can extract their data. There
are two types, each with its own method; both `POST` to `/credentials` and return
`202` (the credential is created with `status: "pending"` while the SAT validates
it asynchronously).

**CIEC** — RFC plus the CIEC password:

```ruby
response = SyntageSdk.credentials.create_ciec(
  rfc: 'LSI240429PHA',
  password: 'your-ciec-password'
)

response.status     # 202
response.body['id'] # the created credential id
```

**e.firma** — the FIEL certificate (`.cer`) and private key (`.key`) plus their
password. Pass the **raw file bytes**; the SDK base64-encodes them for you (the
API requires base64, a detail not stated in its reference):

```ruby
response = SyntageSdk.credentials.create_efirma(
  certificate: File.binread('lsi240429pha.cer'),
  private_key: File.binread('Claveprivada_FIEL.key'),
  password: 'your-efirma-password'
)

response.status     # 202
response.body['rfc'] # derived from the certificate
```

All arguments are required keyword arguments: omitting any raises an
`ArgumentError` before any request is made. For e.firma the SDK uses
`Base64.strict_encode64` (no line breaks), so do not pre-encode the inputs.

### Events

Events report the outcome of asynchronous operations (e.g. `file.created`,
`credential.updated`), so the calling app can learn the result of work it
triggered earlier. `events.list` queries the collection (`GET /events`) and
returns a JSON-LD (Hydra) collection.

```ruby
response = SyntageSdk.events.list(
  type: 'credential.updated',         # event type
  taxpayer_id: 'XAXX010101000',       # filters by taxpayer.id
  source: '/extractions/abc',         # source IRI
  resource: '/credentials/xyz',       # resource IRI
  created_at: { strictly_after: '2026-01-01', before: '2026-06-10' },
  order: 'desc',                      # by createdAt
  items_per_page: 50                  # default 20, max 1000
)

body = response.body
body['hydra:totalItems'] # total number of events (offset paging only)
body['hydra:member']     # the array of events
body['hydra:view']       # navigation links (hydra:next / hydra:previous / first / last)
```

Every argument is optional; unknown keys are ignored. The `created_at` filter
accepts any of `before`, `after`, `strictly_before`, `strictly_after`.

Paging works in two styles. **Offset** (the default) uses `page` and exposes
`hydra:totalItems`:

```ruby
SyntageSdk.events.list(items_per_page: 20, page: 2)
```

**Cursor** is opt-in with `cursor: true` (it sends the `X-Pagination-Style: cursor`
header). It drops `hydra:totalItems`; navigate with the relative IRIs the API
returns in `hydra:view` (`hydra:next` / `hydra:previous`), which already carry the
cursor as query params:

```ruby
page1 = SyntageSdk.events.list(cursor: true, items_per_page: 20)
next_iri = page1.body.dig('hydra:view', 'hydra:next')
# => "/events?itemsPerPage=20&id[lt]=019eb204-..."

page2 = SyntageSdk.client.get(next_iri, headers: { 'Accept' => 'application/ld+json' })
```

The `cursor_next` / `cursor_previous` keyword arguments are forwarded as query
params for APIs that expect explicit cursor tokens.

### Insights

Insights are entity-scoped, so they hang off `SyntageSdk.insights(entity_id)`.
Sub-groups of the API live under it — financial **metrics** are reached through
`.metrics`:

```ruby
insights = SyntageSdk.insights('a1fbec32-...')   # bind the entity once

response = insights.metrics.balance_sheet         # GET .../insights/metrics/balance-sheet
response.body['taxRegime']                        # => { "id" => 601 }
response.body['data']                             # tree of categories (Activo, Pasivo, ...)
```

`balance_sheet` and `income_statement` take the same optional arguments:

```ruby
insights.metrics.balance_sheet(
  format: 2022,                       # X-Insight-Format header (year format: 2014 or 2022)
  from: '2022-01-01T00:00:00Z',       # options[from] — filter by fiscal year (>=)
  to:   '2024-12-31T23:59:59Z'        # options[to]   — filter by fiscal year (<=)
)

insights.metrics.income_statement(format: 2022)   # GET .../insights/metrics/income-statement
```

Both statements are built per **year format**: `2014` (the default, sourced from
annual tax-return transcript PDFs) and `2022` (sourced from financial-statement
XLSXs). If an entity has no data in the default format, the API answers
`400 "Invalid format"` (raised as `SyntageSdk::ValidationError`) — pass
`format: 2022` to select the XLSX format instead.

`scores` takes no arguments — it aggregates the entity's scores from every
configured source (Syntage Score and any third-party providers):

```ruby
insights.metrics.scores            # GET .../insights/metrics/scores
```

Some insights live directly under `/insights/` (not `metrics`), so they hang off
`insights` itself. `financial_ratios` returns liquidity, leverage, profitability,
and efficiency ratios per fiscal year, and accepts the same `from:` / `to:`
date filters (no `format:`):

```ruby
insights.financial_ratios                                  # GET .../insights/financial-ratios
insights.financial_ratios(from: '2022-01-01T00:00:00Z')    # options[from]
```

### Errors and retries

Non-success responses raise:

| Status        | Exception                         | Behavior                                  |
| ------------- | --------------------------------- | ----------------------------------------- |
| `400` / `422` | `SyntageSdk::ValidationError`     | Raised immediately                        |
| `401`         | `SyntageSdk::AuthenticationError` | Raised immediately                        |
| `403`         | `SyntageSdk::ForbiddenError`      | Raised immediately                        |
| `429`         | `SyntageSdk::RateLimitError`      | Retried (`max_retries`, default 2) before raising |
| other         | `SyntageSdk::ApiError`            | Raised immediately                        |

Every API error carries the parsed response body in `error.body`, so the calling
app can read the API's own explanation (e.g. the failed validation fields).

`429` responses are retried with an exponential back-off. Once `max_retries` is
exhausted the `RateLimitError` is raised so the client app can decide what to do.

```ruby
SyntageSdk.configure { |config| config.max_retries = 3 }

begin
  SyntageSdk.client.get('entities')
rescue SyntageSdk::RateLimitError => error
  error.rate_limit.reset_at # when the quota frees up
rescue SyntageSdk::AuthenticationError => error
  error.request_id          # to report to support
end
```

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
| `SyntageSdk::ApiError`           | API failure; exposes `request_id` and `body`            |
| `SyntageSdk::AuthenticationError`| `401` response; an `ApiError` for invalid credentials   |
| `SyntageSdk::ForbiddenError`     | `403` response; the API key lacks permission            |
| `SyntageSdk::ValidationError`    | `400` / `422` response; invalid request data            |
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
