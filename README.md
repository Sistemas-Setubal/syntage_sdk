# Syntage SDK

Ruby SDK for the [Syntage](https://api.syntage.com) API.

It centralizes configuration (authentication and environment) in a single place,
so the client application sets it up once and every request reuses it. It also
exposes the metadata of each response (request identifier and rate limit status)
to make traceability and usage control easy.

## Requirements

- Ruby >= 3.4.0

## Installation

The gem is not published to RubyGems.org; consuming apps point to this
GitHub repository directly, pinned to a release tag:

```ruby
gem 'syntage_sdk', git: 'https://github.com/Sistemas-Setubal/syntage_sdk.git', tag: 'vX.Y.Z'
```

For local development against an unreleased change, point to a path instead:

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

List the entities in your organization (`GET /entities`) as a JSON-LD (Hydra)
collection. `rfc` (mapped to the API's `taxpayer.id` param) and `name` filter by
**partial match**, so compare the returned members when you need an exact RFC;
`person_type` (`physical` / `legal`) is an exact match. Date filters
(`registration_date`, `created_at`, `updated_at`) take a hash of
`before` / `after` / `strictly_before` / `strictly_after`, ordering supports
`created_at` and `updated_at`, and cursor pagination uses `id_lt` / `id_gt`:

```ruby
response = SyntageSdk.entities.list(rfc: 'XAXX010101000')
response.body['hydra:member'] # the matching entities

SyntageSdk.entities.list(
  name: 'Acme',                            # partial match
  person_type: 'legal',
  registration_date: { after: '2020-01-01' },
  order: { updated_at: 'desc' },
  items_per_page: 50
)
```

Retrieve a single entity by id (`GET /entities/:id`, returns `200`):

```ruby
response = SyntageSdk.entities.retrieve('a1fbec32-…')
response.body # the entity, with taxpayer, credential and tag info
```

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

Update an entity by id (`PATCH /entities/:id`, returns `200`). `name` and `tags`
are optional and only sent when provided; passing `tags` (entity tag IRIs)
**replaces** the entity's current tags:

```ruby
response = SyntageSdk.entities.update(
  'a1fbec32-…',
  name: 'Syntage',          # optional
  tags: ['/entity-tags/abc'] # optional, replaces existing tags
)

response.body # the updated entity
```

### Entity tags

Entity tags are reusable labels you can attach to entities.

List entity tags (`GET /entity-tags`) as a JSON-LD collection. The endpoint
supports `items_per_page` and cursor pagination through `id_lt` / `id_gt` (mapped
to the API's `id[lt]` / `id[gt]` params):

```ruby
response = SyntageSdk.entity_tags.list(items_per_page: 20)
response.body['hydra:member'] # the entity tags

# next page, after the last id seen
SyntageSdk.entity_tags.list(items_per_page: 20, id_lt: 'a224731b-…')
```

List the tags of a single entity (`GET /entities/:entity_id/tags`) as a JSON-LD
collection. `entity_id` is a required keyword argument and it accepts the same
`items_per_page` / `id_lt` / `id_gt` options:

```ruby
response = SyntageSdk.entity_tags.list_for_entity(entity_id: 'a21df628-…')
response.body['hydra:member'] # the entity's tags
```

Create an entity tag (`POST /entity-tags`, returns `201`). `name` is the only
field; it is a required keyword argument, so omitting it raises an `ArgumentError`
before any request is made:

```ruby
response = SyntageSdk.entity_tags.create(name: 'vip')

response.status     # 201
response.body['id'] # the created entity tag id
```

Retrieve a single entity tag by id (`GET /entity-tags/:id`) as a JSON-LD object:

```ruby
response = SyntageSdk.entity_tags.retrieve('a224731b-…')
response.body # the entity tag
```

Update an entity tag's name (`PATCH /entity-tags/:id`, returns `200`). The request
is sent as a JSON merge patch:

```ruby
response = SyntageSdk.entity_tags.update('a224731b-…', name: 'premium')
response.body # the updated entity tag
```

Delete an entity tag by id (`DELETE /entity-tags/:id`, returns `204`):

```ruby
response = SyntageSdk.entity_tags.destroy('a224731b-…')
response.status # 204
```

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

### Extractions

Trigger a one-off SAT data extraction for an entity (`POST /extractions`,
returns `202`). The entity needs a valid credential for the requested
`extractor` beforehand (see [Credentials](#credentials)):

```ruby
response = SyntageSdk.extractions.create(
  entity: '/entities/a1fd8884-339d-4b4a-ba8f-9bb1231dddc9', # required, entity IRI
  extractor: 'tax_status',                                  # required
  options: { period: { from: '2026-01-01' } }                # optional, extractor-specific
)

response.status     # 202
response.body['id'] # the created extraction id
```

`entity` and `extractor` are required keyword arguments: omitting either raises
an `ArgumentError` before any request is made. `extractor` is not validated
client-side (a value the API doesn't recognize surfaces as a `ValidationError`);
known values include `tax_status`, `rif_tax_return`, `annual_tax_return`,
`monthly_tax_return`, `electronic_accounting`, `rpc`, `rug`,
`buro_de_credito_report`, `invoice`, `tax_retention`, `tax_compliance`,
`background_check` and `sat_certificates`. `options` is optional and only sent
when provided; some extractors (e.g. `annual_tax_return`) apply a default when
it's omitted. `POST /extractions` can return `409 Conflict` if there's already
a pending extraction for the same entity/extractor pair.

List extractions (`GET /extractions`) as a JSON-LD collection:

```ruby
response = SyntageSdk.extractions.list(
  extractor: 'tax_status',
  status: 'finished',           # pending · finished · error, etc.
  datasource: 'sat',
  taxpayer_id: 'XAXX010101000', # filters by taxpayer.id
  started_at: { after: '2026-01-01' },
  finished_at: { before: '2026-06-01' },
  order: { started_at: 'desc' }, # or a plain string, ordered by createdAt
  items_per_page: 50
)

response.body['hydra:member'] # the extractions
```

Every argument is optional; unknown keys are ignored. Retrieve a single
extraction by id (`GET /extractions/:id`):

```ruby
response = SyntageSdk.extractions.retrieve('a239f1c7-…')
response.body['status'] # pending · finished · error, etc.
```

Stop an in-progress extraction (`DELETE /extractions/:id/stop`, returns `204`).
The API returns `409` if the extraction is no longer stoppable (e.g. already
finished):

```ruby
response = SyntageSdk.extractions.stop('a239f1c7-…')
response.status # 204
```

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

### Invoices

Query the SAT invoices that belong to an entity (`GET /entities/:id/invoices`).
The response is a JSON-LD (Hydra) collection.

```ruby
response = SyntageSdk.invoices.list(
  entity_id: 'a1fd8884-339d-4b4a-ba8f-9bb1231dddc9', # required
  type:            'I',               # I · E · P · N · T
  status:          'VIGENTE',         # VIGENTE · CANCELADO
  payment_method:  'PUE',            # PUE · PPD
  issuer_rfc:      'XAXX010101000',
  is_issuer:       true,
  currency:        'MXN',
  has_xml:         true,
  issued_at:       { after: '2026-01-01', before: '2026-06-01' },
  total:           { gte: 1000 },
  order:           { issued_at: 'desc' },
  items_per_page:  50
)

body = response.body
body['hydra:totalItems'] # total invoices (offset paging only)
body['hydra:member']     # array of invoices
body['hydra:view']       # navigation links
```

`entity_id` is required; every other argument is optional. Unknown keys are
ignored.

**Filters** — all mapped to their camelCase API equivalents:

| Ruby key | API param |
| --- | --- |
| `uuid` | `uuid` |
| `version` | `version` |
| `type` | `type` |
| `usage` | `usage` |
| `payment_type` | `paymentType` |
| `payment_method` | `paymentMethod` |
| `issuer_rfc` / `issuer_name` / `issuer_tax_regime` / `issuer_blacklist_status` | `issuer.*` |
| `is_issuer` | `isIssuer` |
| `receiver_rfc` / `receiver_name` / `receiver_blacklist_status` | `receiver.*` |
| `is_receiver` | `isReceiver` |
| `currency` | `currency` |
| `status` | `status` |
| `pac` | `pac` |
| `cancellation_status` / `cancellation_status_process` | `cancellationStatus*` |
| `has_xml` / `has_pdf` | `hasXml` / `hasPdf` |
| `exists_payment_method` | `exists[paymentMethod]` |
| `id_lt` / `id_gt` | `id[lt]` / `id[gt]` |

**Date filters** — `issued_at`, `canceled_at`, `updated_at`, `certified_at`,
`last_payment_date`, `fully_paid_at`, and `created_at` each accept a hash with
any of `before`, `strictly_before`, `after`, `strictly_after`:

```ruby
SyntageSdk.invoices.list(
  entity_id: 'ent_123',
  issued_at: { strictly_after: '2026-01-01', before: '2026-06-01' }
)
```

**Numeric range filters** — `tax`, `discount`, `subtotal`, `total`,
`paid_amount`, and `due_amount` accept a hash with any of `gt`, `gte`, `lt`,
`lte`, `between`:

```ruby
SyntageSdk.invoices.list(entity_id: 'ent_123', total: { gte: 1000, lt: 50_000 })
```

**Ordering** — pass an `order:` hash with any of `issued_at`, `canceled_at`,
`certified_at`, `amount`, each set to `'asc'` or `'desc'`:

```ruby
SyntageSdk.invoices.list(entity_id: 'ent_123', order: { issued_at: 'desc', amount: 'asc' })
```

This endpoint **only supports cursor pagination** — passing `page:` raises a
`SyntageSdk::ValidationError`. The API always returns cursor links in
`hydra:view`; navigate using the IRIs it provides:

```ruby
page1 = SyntageSdk.invoices.list(entity_id: 'ent_123', items_per_page: 20)
next_iri = page1.body.dig('hydra:view', 'hydra:next')
# => "/entities/ent_123/invoices?itemsPerPage=20&id%5Blt%5D=..."

page2 = SyntageSdk.client.get(next_iri, headers: { 'Accept' => 'application/ld+json' })
```

#### Retrieve a single invoice

Fetch one invoice by its UUID (`GET /invoices/:id`). This endpoint is global —
the UUID identifies the invoice directly, so no `entity_id` is required.

```ruby
response = SyntageSdk.invoices.retrieve('91106968-1abd-4d64-85c1-4e73d96fb997')
response.body # the invoice as a JSON-LD resource
```

#### Retrieve an invoice's CFDI

Fetch the CFDI of an invoice (`GET /invoices/:id/cfdi`) in one of three formats,
selected with `format:` (default `:json`). The format drives the `Accept` header
and how the response body comes back:

| `format:` | `Accept` | `response.body` |
| --- | --- | --- |
| `:json` (default) | `application/json` | the CFDI parsed into a Hash |
| `:xml` | `text/xml` | the original XML as a raw String |
| `:pdf` | `application/pdf` | the PDF as raw bytes (String) |

```ruby
id = '91106968-1abd-4d64-85c1-4e73d96fb997'

SyntageSdk.invoices.cfdi(id)               # => body is a Hash
SyntageSdk.invoices.cfdi(id, format: :xml) # => body is the raw XML

pdf = SyntageSdk.invoices.cfdi(id, format: :pdf)
File.binwrite('invoice.pdf', pdf.body)
```

Any other `format:` raises `ArgumentError`.

### Insights

Insights are analytics computed from an entity's data. Get an entity-scoped
insights object with `SyntageSdk.insights(entity_id)`; the top-level analytics
hang off it directly, and related metrics are grouped under `metrics`,
`accounting`, `concentration` and `products` accessors. Every insight is a `GET`
that returns `200`.

```ruby
insights = SyntageSdk.insights('a1fd8884-…')
```

Most insights accept an optional `from:` / `to:` date window (sent as the API's
`options[from]` / `options[to]` query params); `summary` and `scores` take no
arguments.

The analytics that live directly under `/insights/` hang off `insights` itself:

```ruby
insights.summary                                       # GET .../insights/summary
insights.sales_revenue(from: '2022-01-01T00:00:00Z')   # GET .../insights/sales-revenue
insights.expenditures                                  # GET .../insights/expenditures
insights.financial_institutions                        # GET .../insights/financial-institutions
insights.employees                                     # GET .../insights/employees
insights.rpc_shareholders                              # GET .../insights/rpc-shareholders
insights.government_customers                          # GET .../insights/government-customers
insights.invoicing_blacklist                           # GET .../insights/invoicing-blacklist
insights.risks                                         # GET .../insights/risks
```

#### Metrics

The insights under `/insights/metrics/` hang off `insights.metrics`:

```ruby
insights.metrics.scores                       # GET .../insights/metrics/scores
insights.metrics.balance_sheet                # GET .../insights/metrics/balance-sheet
insights.metrics.income_statement             # GET .../insights/metrics/income-statement
insights.metrics.customer_network             # GET .../insights/metrics/customer-network
insights.metrics.vendor_network               # GET .../insights/metrics/vendor-network
insights.metrics.invoicing_annual_comparison  # GET .../insights/metrics/invoicing-annual-comparison
```

`scores` takes no arguments — it aggregates the entity's scores from every
configured source (Syntage Score and any third-party providers). `balance_sheet`,
`income_statement` and `invoicing_annual_comparison` accept `from:` / `to:` plus an
optional `format:`, which is forwarded as the `X-Insight-Format` request header:

```ruby
insights.metrics.balance_sheet(from: '2022-01-01T00:00:00Z', to: '2022-12-31T23:59:59Z')
insights.metrics.income_statement(format: 'condensed')
```

#### Accounting

Accounting insights hang off `insights.accounting`. Besides `from:` / `to:`, some
accept `periodicity:` (`yearly` — the default — or `monthly`), and `cash_flow_stats`
also accepts `type:`:

```ruby
insights.accounting.financial_ratios                        # GET .../insights/financial-ratios
insights.accounting.trial_balance(periodicity: 'monthly')   # GET .../insights/trial-balance
insights.accounting.cash_flow_stats(periodicity: 'monthly') # GET .../insights/cash-flow-stats
insights.accounting.accounts_payable                        # GET .../insights/accounts-payable
insights.accounting.accounts_receivable                     # GET .../insights/accounts-receivable
```

`financial_ratios` returns liquidity, leverage, profitability and efficiency ratios
per fiscal year; `trial_balance` returns the trial-balance accounts.

#### Concentration

Concentration insights hang off `insights.concentration`. `invoicing` requires a
`type:` argument; `customer` and `supplier` accept only `from:` / `to:`:

```ruby
insights.concentration.invoicing(type: 'issued')  # GET .../insights/invoicing-concentration
insights.concentration.customer                    # GET .../insights/customer-concentration
insights.concentration.supplier                    # GET .../insights/supplier-concentration
```

#### Products

Products insights hang off `insights.products`, listing the products and services
the entity sold or bought (both accept `from:` / `to:`):

```ruby
insights.products.sold    # GET .../insights/products-and-services-sold
insights.products.bought  # GET .../insights/products-and-services-bought
```

### Tax returns

List an entity's tax returns (`GET /entities/:entity_id/tax-returns`) as a JSON-LD
(Hydra) collection. `entity_id:` is required. Filters: `type`, `interval_unit`,
`complementary`, `capture_line`, `operation_number`, `fiscal_year`, `period`; date
ranges on `presented_at` and `created_at`
(`{ before:, after:, strictly_before:, strictly_after: }`); ordering via
`order: { period:, presented_at: }`; and the usual cursor pagination
(`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.tax_returns.list(
  entity_id: '91106968-…',
  fiscal_year: 2026,
  order:       { presented_at: 'desc' }
)

body = response.body
body['hydra:member'] # array of tax returns
body['hydra:view']   # cursor navigation links
```

Retrieve a single tax return by id (`GET /tax-returns/:id`) as a JSON-LD object:

```ruby
response = SyntageSdk.tax_returns.retrieve('91106968-…')
response.body # the tax return record
```

Fetch the parsed data of a tax return (`GET /tax-returns/:id/data`) as JSON:

```ruby
response = SyntageSdk.tax_returns.data('91106968-…')
response.body # the tax return data
```

### Shareholders

List an entity's shareholders (`GET /entities/:entity_id/shareholders`) as a
JSON-LD (Hydra) collection. `entity_id:` is required. Filters: `type`, `name`,
`rfc`; ordering via `order: { name:, created_at:, updated_at: }`; and the usual
cursor pagination (`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.shareholders.list(
  entity_id: '91106968-…',
  order:     { name: 'asc' }
)

body = response.body
body['hydra:member'] # array of shareholders
body['hydra:view']   # cursor navigation links
```

List every shareholder across entities (`GET /shareholders`) with the same filters,
ordering and pagination:

```ruby
response = SyntageSdk.shareholders.list_all(rfc: 'XAXX010101000')
response.body['hydra:member'] # array of shareholders
```

Retrieve a single shareholder by id (`GET /shareholders/:id`) as a JSON-LD object:

```ruby
response = SyntageSdk.shareholders.retrieve('91106968-…')
response.body # the shareholder record
```

Register a shareholder for an entity (`POST /entities/:entity_id/shareholders`,
returns `201`). `entity_id:`, `relation_type:`, `name:` and `shares:` are required
keyword arguments (omitting any raises an `ArgumentError` before any request is
made); `rfc:` is optional:

```ruby
response = SyntageSdk.shareholders.create(
  entity_id:     '91106968-…',
  relation_type: 'shareholder',
  name:          'Jane Doe',
  shares:        150,
  rfc:           'XAXX010101000' # optional
)

response.status     # 201
response.body['id'] # the created shareholder id
```

Update a shareholder by id (`PATCH /shareholders/:id`, returns `200`). `name` and
`rfc` are optional and only sent when provided:

```ruby
response = SyntageSdk.shareholders.update('91106968-…', name: 'Jane A. Doe')
response.body # the updated shareholder
```

Delete a shareholder by id (`DELETE /shareholders/:id`, returns `204`):

```ruby
response = SyntageSdk.shareholders.destroy('91106968-…')
response.status # 204
```

### SAT certificates

Get the SAT digital certificates (CSD/FIEL) of an entity
(`GET /entities/:entity_id/datasources/mx/sat/certificados`) as a JSON-LD (Hydra)
collection. Bind the resource to an entity with `SyntageSdk.sat_certificates(entity_id)`.
Filters: `serial_number`, `type`; date ranges on `valid_from`, `valid_to` and
`created_at` (`{ before:, after:, strictly_before:, strictly_after: }`); ordering via
`order: { valid_from:, valid_to: }`; and the usual cursor pagination
(`id_lt` / `id_gt`, `items_per_page`).

```ruby
certificates = SyntageSdk.sat_certificates('91106968-…')

response = certificates.list(type: 'CSD', order: { valid_to: 'desc' })
response.body['hydra:member'] # array of SAT certificates
```

Retrieve a single certificate by id (`GET /datasources/mx/sat/certificados/:id`) as
a JSON-LD object:

```ruby
response = certificates.retrieve('91106968-…')
response.body # the SAT certificate
```

`check_expiry` is a convenience wrapper over `list` that returns the certificates
expiring within a window — those whose `valid_to` is after today but before
`threshold_days` from now (default `30`):

```ruby
certificates.check_expiry                     # expiring within 30 days
certificates.check_expiry(threshold_days: 90) # expiring within 90 days
```

### RUG (movable-property guarantees)

The RUG (Registro Único de Garantías Mobiliarias) datasource exposes an entity's
guarantees and operations. Bind the resource to an entity with
`SyntageSdk.rug(entity_id)`. The list endpoints return JSON-LD (Hydra) collections
with the usual cursor pagination (`id_lt` / `id_gt`, `items_per_page`).

```ruby
rug = SyntageSdk.rug('91106968-…')

rug.guarantees(items_per_page: 50)  # GET .../datasources/rug/garantias
rug.operations(items_per_page: 50)  # GET .../datasources/rug/operaciones
```

Retrieve a single guarantee or operation by id:

```ruby
rug.guarantee('91106968-…')  # GET /datasources/rug/garantias/:id
rug.operation('91106968-…')  # GET /datasources/rug/operaciones/:id
```

### RPC entities

The RPC (Registro Público de Comercio) datasource exposes the commercial-registry
records tied to an entity. Bind the resource with `SyntageSdk.rpc_entities(entity_id)`.

```ruby
rpc = SyntageSdk.rpc_entities('91106968-…')

response = rpc.list(items_per_page: 50) # GET .../datasources/rpc/entidades
response.body['hydra:member']           # array of RPC records
```

Retrieve a single RPC record by id (`GET /datasources/rpc/entidades/:id`):

```ruby
response = rpc.retrieve('91106968-…')
response.body # the RPC record
```

### Syntage Score

Trigger the calculation of an entity's Syntage Score
(`POST /entities/:entity_id/datasources/syntage/score/calculate`, returns `202`).
Bind the resource with `SyntageSdk.syntage_score(entity_id)`. The calculation runs
asynchronously; the request takes no body:

```ruby
response = SyntageSdk.syntage_score('91106968-…').calculate
response.status # 202
```

### Tags

Tags are labels you can attach to any taggable resource (invoices, entities, …),
distinct from entity tags. List tags (`GET /tags`) as a JSON-LD collection with the
usual cursor pagination (`id_lt` / `id_gt`, `items_per_page`):

```ruby
response = SyntageSdk.tags.list(items_per_page: 20)
response.body['hydra:member'] # the tags
```

Create a tag (`POST /tags`, returns `202`). `name:` and `resource_type:` are
required keyword arguments; `resource_id:` is optional and only sent when provided.
`resource_type` and `resource_id` are mapped to the API's `resourceType` /
`resourceId` fields:

```ruby
response = SyntageSdk.tags.create(
  name:          'audited',
  resource_type: 'invoice',
  resource_id:   '/invoices/91106968-…' # optional
)

response.status     # 202
response.body['id'] # the created tag id
```

Update a tag's name (`PATCH /tags/:id`, returns `200`):

```ruby
response = SyntageSdk.tags.update('91106968-…', name: 'reviewed')
response.body # the updated tag
```

Delete a tag by id (`DELETE /tags/:id`, returns `204`):

```ruby
response = SyntageSdk.tags.destroy('91106968-…')
response.status # 204
```

### Addresses

Look up the neighborhoods (colonias) and municipality for a Mexican postal code
(`GET /datasources/mx/addresses/:postal_code`, returns `200`):

```ruby
response = SyntageSdk.addresses.lookup('64000')
response.body # the neighborhoods and municipality for the postal code
```

### Payments

List payments as a JSON-LD (Hydra) collection. Without arguments it returns the
payments across every invoice (`GET /invoices/payments`); pass `invoice_id:` to
scope it to a single invoice (`GET /invoices/:id/payments`).

```ruby
response = SyntageSdk.payments.list(items_per_page: 50)        # all payments
SyntageSdk.payments.list(invoice_id: '91106968-…')             # one invoice's payments

body = response.body
body['hydra:member'] # array of payments
body['hydra:view']   # cursor navigation links
```

Cursor pagination uses `id_lt` / `id_gt` (mapped to `id[lt]` / `id[gt]`); pass the
ids from the `hydra:view` links to move between pages:

```ruby
SyntageSdk.payments.list(id_lt: 'a1fd895b-5dcb-4cb4-89bc-3467f460c75b', items_per_page: 50)
```

Fetch a single payment by its UUID (`GET /invoices/payments/:id`):

```ruby
response = SyntageSdk.payments.retrieve('91106968-1abd-4d64-85c1-4e73d96fb997')
response.body # the payment as a JSON-LD resource
```

### Batch payments

List batch payments as a JSON-LD (Hydra) collection. Without arguments it returns
the batch payments across every invoice (`GET /invoices/batch-payments`); pass
`invoice_id:` to scope it to a single invoice (`GET /invoices/:id/batch-payments`).
Same cursor pagination as payments (`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.batch_payments.list(items_per_page: 50)   # all batch payments
SyntageSdk.batch_payments.list(invoice_id: '91106968-…')        # one invoice's batch payments

body = response.body
body['hydra:member'] # array of batch payments
body['hydra:view']   # cursor navigation links
```

Fetch a single batch payment by its UUID (`GET /invoices/batch-payments/:id`):

```ruby
response = SyntageSdk.batch_payments.retrieve('91106968-1abd-4d64-85c1-4e73d96fb997')
response.body # the batch payment as a JSON-LD resource
```

### Line items

List the line items of an invoice (`GET /invoices/:id/line-items`) as a JSON-LD
(Hydra) collection. `invoice_id:` is required; pagination matches the other
collections (`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.line_items.list(invoice_id: '91106968-…', items_per_page: 50)

body = response.body
body['hydra:member'] # array of line items
body['hydra:view']   # cursor navigation links
```

### Credit notes

List credit notes across invoices (`GET /invoices/credit-notes`) as a JSON-LD
(Hydra) collection. Same cursor pagination as the other collections (`id_lt` /
`id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.credit_notes.list(items_per_page: 50)

body = response.body
body['hydra:member'] # array of credit notes
body['hydra:view']   # cursor navigation links
```

List the credit notes related to a given invoice — the ones it **issued**
(`GET /invoices/:id/issued-credit-notes`) or the ones **applied** to it
(`GET /invoices/:id/applied-credit-notes`):

```ruby
SyntageSdk.credit_notes.issued(invoice_id: '91106968-…')
SyntageSdk.credit_notes.applied(invoice_id: '91106968-…')
```

Fetch a single credit note by its UUID (`GET /invoices/credit-note/:id` — note the
singular `credit-note`):

```ruby
response = SyntageSdk.credit_notes.retrieve('91106968-1abd-4d64-85c1-4e73d96fb997')
response.body # the credit note as a JSON-LD resource
```

### Tax status

List a taxpayer's tax status history (`GET /entities/:entity_id/tax-status`) as a
JSON-LD (Hydra) collection. `entity_id:` is required; pagination matches the other
collections (`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.tax_status.list(entity_id: '91106968-…', items_per_page: 50)

body = response.body
body['hydra:member'] # array of tax status records
body['hydra:view']   # cursor navigation links
```

Retrieve a single tax status by id (`GET /tax-status/:id`) as a JSON-LD object:

```ruby
response = SyntageSdk.tax_status.retrieve('91106968-…')
response.body # the tax status record
```

### Tax compliance checks

List a taxpayer's compliance opinions (`GET /entities/:entity_id/tax-compliance-checks`)
as a JSON-LD (Hydra) collection. `entity_id:` is required. Filters: `internal_identifier`,
`taxpayer_rfc`, `taxpayer_name`, `result` (`positive` / `negative` / `no_obligations` /
`activity_suspended`); date ranges on `checked_at` and `created_at`
(`{ before:, after:, strictly_before:, strictly_after: }`); ordering via
`order: { checked_at:, created_at: }`; and the usual cursor pagination
(`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.tax_compliance_checks.list(
  entity_id: '91106968-…',
  result:    'positive',
  order:     { checked_at: 'desc' }
)

body = response.body
body['hydra:member'] # array of compliance checks
body['hydra:view']   # cursor navigation links
```

Retrieve a single compliance check by id (`GET /tax-compliance-checks/:id`) as a
JSON-LD object:

```ruby
response = SyntageSdk.tax_compliance_checks.retrieve('91106968-…')
response.body # the compliance check record
```

### Tax retentions

List a taxpayer's tax retentions (`GET /entities/:entity_id/tax-retentions`) as a
JSON-LD (Hydra) collection. `entity_id:` is required. Filters: `uuid`, `version`,
`internal_identifier`, `pac`, `code`, `issuer_rfc`, `issuer_name`, `issuer_curp`,
`receiver_rfc`, `receiver_name`, `receiver_curp`, `receiver_nationality`, `has_xml`,
`has_pdf`; numeric ranges on `total_operation_amount`, `total_taxable_amount`,
`total_exempt_amount` and `total_retained_amount`
(`{ gt:, gte:, lt:, lte:, between: }`, e.g. `between: '12.99..15.99'`); date ranges on
`issued_at`, `canceled_at`, `certified_at`, `period_from`, `period_to` and `created_at`
(`{ before:, after:, strictly_before:, strictly_after: }`); ordering via
`order: { issued_at:, canceled_at:, certified_at:, period_from:, period_to:,
total_operation_amount:, total_taxable_amount:, total_exempt_amount:,
total_retained_amount: }`; and the usual cursor pagination
(`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.tax_retentions.list(
  entity_id:             '91106968-…',
  total_retained_amount: { gte: '100.00' },
  order:                 { issued_at: 'desc' }
)

body = response.body
body['hydra:member'] # array of tax retentions
body['hydra:view']   # cursor navigation links
```

Retrieve a single retention by id (`GET /tax-retentions/:id`) as a JSON-LD object:

```ruby
response = SyntageSdk.tax_retentions.retrieve('91106968-…')
response.body # the tax retention record
```

Fetch the retention's CFDI (`GET /tax-retentions/:id/cfdi`) in one of three formats,
selected with `format:` (default `:json`), exactly like `invoices.cfdi`:

| `format:` | `Accept` | `response.body` |
| --- | --- | --- |
| `:json` (default) | `application/json` | the CFDI parsed into a Hash |
| `:xml` | `text/xml` | the original XML as a raw String |
| `:pdf` | `application/pdf` | the PDF as raw bytes (String) |

```ruby
id = '91106968-1abd-4d64-85c1-4e73d96fb997'

SyntageSdk.tax_retentions.cfdi(id)               # => body is a Hash
SyntageSdk.tax_retentions.cfdi(id, format: :xml) # => body is the raw XML

pdf = SyntageSdk.tax_retentions.cfdi(id, format: :pdf)
File.binwrite('retention.pdf', pdf.body)
```

Any other `format:` raises `ArgumentError`.

### Electronic accounting

List a entity's electronic accounting records
(`GET /entities/:entity_id/electronic-accounting-records`) as a JSON-LD (Hydra)
collection. `entity_id:` is required. Filters: `year`, `month`, `type` (`N` / `C`),
`reason` (`AF` / `DE` / `CO` / `FC` / `EM`), `file_type` (`CT` / `B` / `PL` / `XF` /
`XC`), `filename`, `code`, `status` (`received` / `accepted` / `rejected`); date ranges
on `received_at` (`{ before:, after:, strictly_before:, strictly_after: }`); ordering via
`order: { year:, month:, received_at: }`; and the usual cursor pagination
(`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.electronic_accounting.list(
  entity_id: '91106968-…',
  year:      2026,
  order:     { received_at: 'desc' }
)

body = response.body
body['hydra:member'] # array of electronic accounting records
body['hydra:view']   # cursor navigation links
```

Retrieve a single record by id (`GET /electronic-accounting-records/:id`) as a
JSON-LD object:

```ruby
response = SyntageSdk.electronic_accounting.retrieve('91106968-…')
response.body # the electronic accounting record
```

### Background checks

List an entity's background checks (`GET /entities/:entity_id/background-checks`) as a
JSON-LD (Hydra) collection. `entity_id:` is required. Filters: `status` (`pending` /
`completed` / `error`), `country` (`MX` / `ALL`); ordering via
`order: { score:, created_at:, updated_at: }`; and the usual cursor pagination
(`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.background_checks.list(
  entity_id: '91106968-…',
  status:    'completed',
  order:     { score: 'desc' }
)

body = response.body
body['hydra:member'] # array of background checks
body['hydra:view']   # cursor navigation links
```

List every background check across entities (`GET /background-checks`) with the same
filters, ordering and pagination:

```ruby
response = SyntageSdk.background_checks.list_all(country: 'MX')
response.body['hydra:member'] # array of background checks
```

Retrieve a single background check by id (`GET /background-checks/:id`) as a JSON-LD
object:

```ruby
response = SyntageSdk.background_checks.retrieve('91106968-…')
response.body # the background check record
```

Get the background check's PDF report (`GET /background-checks/:id/pdf`). Despite its
name, this endpoint does **not** return the PDF bytes — it returns a JSON object with a
short-lived, presigned URL you download the file from:

```ruby
response = SyntageSdk.background_checks.pdf('91106968-…')
response.body['url'] # => "https://…s3…/…background_check_report.pdf?X-Amz-…"
```

List a background check's records (`GET /background-checks/:id/records`) as a JSON-LD
collection. Filter by `category` (e.g. `criminal_record`, `legal_background`,
`politically_exposed_person`, …); ordering via `order: { created_at:, updated_at: }`;
and the usual cursor pagination (`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.background_checks.records(
  '91106968-…',
  category: 'criminal_record'
)
response.body['hydra:member'] # array of records
```

### Company verification reports

List an entity's company verification reports
(`GET /entities/:entity_id/datasources/mx/company-verification/reports`) as a JSON-LD
(Hydra) collection. `entity_id:` is required. Ordering via
`order: { created_at:, updated_at: }`; and the usual cursor pagination
(`id_lt` / `id_gt`, `items_per_page`).

```ruby
response = SyntageSdk.company_verification_reports.list(
  entity_id: '91106968-…',
  order:     { created_at: 'desc' }
)

body = response.body
body['hydra:member'] # array of company verification reports
body['hydra:view']   # cursor navigation links
```

List every company verification report across entities
(`GET /datasources/mx/company-verification/reports`) with the same ordering and
pagination:

```ruby
response = SyntageSdk.company_verification_reports.list_all(items_per_page: 50)
response.body['hydra:member'] # array of company verification reports
```

Retrieve a single company verification report by id
(`GET /datasources/mx/company-verification/reports/:id`) as a JSON-LD object:

```ruby
response = SyntageSdk.company_verification_reports.retrieve('91106968-…')
response.body # the company verification report
```

### Schedulers

List schedulers (`GET /schedulers`) as a JSON-LD collection. The endpoint supports
`items_per_page` and cursor pagination through `id_lt` / `id_gt` (mapped to the
API's `id[lt]` / `id[gt]` params):

```ruby
response = SyntageSdk.schedulers.list(items_per_page: 20)
response.body['hydra:member'] # the schedulers

# next page, after the last id seen
SyntageSdk.schedulers.list(items_per_page: 20, id_lt: '91106968-…')
```

Create a scheduler that drives recurring extractions (`POST /schedulers`,
returns `202`).

```ruby
response = SyntageSdk.schedulers.create(
  name: 'Daily extractions', # optional
  is_enabled: true,          # optional, defaults to true on the API
  tags: ['/entity-tags/abc'] # optional, entity tag IRIs
)

response.status     # 202
response.body['id'] # the created scheduler id
```

`type` defaults to `'recurring'` (the only value the API accepts when creating a
scheduler) and can be overridden. `name`, `is_enabled` and `tags` are optional and
only sent when provided; `is_enabled` is mapped to the API's `isEnabled` field, so
passing `is_enabled: false` creates a disabled scheduler.

Retrieve a single scheduler by id (`GET /schedulers/:id`) as a JSON-LD object
that includes its rules and tags:

```ruby
response = SyntageSdk.schedulers.retrieve('91106968-…')
response.body # the scheduler, with its rules and tags
```

Update a scheduler by id (`PUT /schedulers/:id`, returns `200`):

```ruby
response = SyntageSdk.schedulers.update(
  '91106968-…',
  name: 'Weekly extractions', # optional
  is_enabled: false,          # optional
  tags: ['/entity-tags/abc']  # optional, entity tag IRIs
)

response.body # the updated scheduler
```

`name`, `is_enabled` and `tags` are optional and only sent when provided;
`is_enabled` is mapped to the API's `isEnabled` field.

Delete a scheduler by id (`DELETE /schedulers/:id`, returns `204`):

```ruby
response = SyntageSdk.schedulers.destroy('91106968-…')
response.status # 204
```

### Scheduler rules

Scheduler rules attach an extractor to a scheduler so it runs on a cron schedule.

Create a rule (`POST /schedulers/rules`, returns `202`). `scheduler` (a scheduler
IRI) and `extractor` are required; `options` and `cron_expression` are optional:

```ruby
response = SyntageSdk.scheduler_rules.create(
  scheduler: '/schedulers/91106968-…', # required, scheduler IRI
  extractor: 'invoice',                # required, e.g. invoice, tax_status, rug
  cron_expression: '@daily',           # optional, mapped to cronExpression
  options: {                           # optional, extractor-specific, sent as-is
    types: ['I', 'E', 'P'],
    period: { from: '2020-01-01T00:00:00.000Z', to: '2020-03-31T23:59:59.000Z' }
  }
)

response.status     # 202
response.body['id'] # the created rule id
```

`cron_expression` is mapped to the API's `cronExpression` field. The `options`
Hash is forwarded verbatim — its inner keys are **not** camelCased, so use the
names each extractor expects (see the API reference for valid options per
extractor).

Retrieve a single rule by id (`GET /schedulers/rules/:id`) as a JSON-LD object:

```ruby
response = SyntageSdk.scheduler_rules.retrieve('e0a24894-…')
response.body # the rule
```

Update a rule by id (`PUT /schedulers/rules/:id`, returns `200`). All fields are
optional for partial updates:

```ruby
response = SyntageSdk.scheduler_rules.update(
  'e0a24894-…',
  extractor: 'tax_status',   # optional
  cron_expression: '@weekly', # optional, mapped to cronExpression
  options: { types: ['I'] }   # optional
)

response.body # the updated rule
```

Delete a rule by id (`DELETE /schedulers/rules/:id`, returns `204`):

```ruby
response = SyntageSdk.scheduler_rules.destroy('e0a24894-…')
response.status # 204
```

### Exports

Generate an export of a collection's data as a file (`POST /exports`, returns
`202`). `format` (`csv`, `xlsx` or `json`) and `uri` (the collection to export,
e.g. an entity's invoices) are required; `file_types` is optional and mapped to
the API's `fileTypes` field:

```ruby
response = SyntageSdk.exports.create(
  format: 'csv',                                        # required: csv, xlsx or json
  uri: '/entities/a1fbec32-…/invoices',                 # required, collection to export
  file_types: ['invoice.cfdi.xml', 'invoice.cfdi.pdf'] # optional
)

response.status     # 202
response.body['id'] # the created export id
```

The export runs asynchronously, so the response comes back with a `pending` /
`running` status. Poll the export by id to get its final status and the generated
file (`GET /exports/:id`) as a JSON-LD object:

```ruby
response = SyntageSdk.exports.retrieve('a1fbec32-…')
response.body['status'] # pending, running, finished or failed
response.body['file']   # the generated file, once finished
```

### Files

Retrieve a file's metadata by id (`GET /files/:id`, returns `200`) as a JSON-LD
object. The metadata includes its `type`, `mimeType`, `extension`, `size`,
`filename` and the IRI of the resource it belongs to:

```ruby
response = SyntageSdk.files.retrieve('91106968-…')
response.body['filename'] # the suggested filename
response.body['mimeType'] # the media type
```

This endpoint returns metadata only, not the file bytes.

Download the file content by id (`GET /files/:id/download`, returns `200`). The
API responds with a redirect to a short-lived download URL, which HTTParty follows
automatically, so `response.body` holds the raw file bytes (XML, PDF, XLSX, JSON
or ZIP). The request accepts any content type, so the bytes are never parsed:

```ruby
response = SyntageSdk.files.download('91106968-…')
File.binwrite('invoice.pdf', response.body)
```

Pair it with `retrieve` to get the right filename and extension for the bytes.

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

## Webhooks

Syntage can push events to your server over HTTP. The SDK ships a Rack middleware
(`SyntageSdk::Webhook::Middleware`) that verifies the HMAC-SHA256 signature on
every incoming request and exposes a parsed `Event` object to your handler.

### Mounting the middleware

**Rails** — add it in `config/application.rb` (or an initializer):

```ruby
config.middleware.use SyntageSdk::Webhook::Middleware,
                      secret: ENV.fetch('SYNTAGE_WEBHOOK_SECRET')
```

**Sinatra / bare Rack** — add it to your `config.ru`:

```ruby
use SyntageSdk::Webhook::Middleware, secret: ENV.fetch('SYNTAGE_WEBHOOK_SECRET')
run Sinatra::Application
```

If you omit `secret:`, the middleware reads `ENV['SYNTAGE_WEBHOOK_SECRET']`
automatically. Requests with an invalid or missing signature return `401`;
requests with an unparseable JSON body return `400`.

### Handling events

The middleware stores the parsed event in `env['syntage.webhook_event']`
before calling the next app. Read it from your controller or route handler:

```ruby
# Rails controller
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    event = request.env['syntage.webhook_event']

    case event.type
    when 'credential.updated'
      # handle credential update
    when 'file.created'
      # handle new file
    end

    head :ok
  end
end
```

```ruby
# Sinatra route
post '/webhooks' do
  event = env['syntage.webhook_event']
  # event.id, event.type, event.resource, event.data, event.created_at
  status 200
end
```

The `Event` struct exposes:

| Field        | Description                                   |
| ------------ | --------------------------------------------- |
| `id`         | Unique event identifier                        |
| `type`       | Event type string (e.g. `"credential.updated"`) |
| `resource`   | IRI of the related resource                   |
| `data`       | Event payload hash                            |
| `created_at` | ISO-8601 timestamp                            |

### Secret rotation

The middleware rejects events signed with a different secret and ignores
timestamps older than 5 minutes (`TIMESTAMP_TOLERANCE = 300`). To rotate
the webhook secret without dropping in-flight events, use a short dual-secret
window:

1. Generate the new secret in the Syntage dashboard (the old one stays active).
2. Deploy a thin wrapper that tries both secrets before rejecting the request:

```ruby
# config/application.rb (or config.ru)
class DualSecretWebhookMiddleware
  def initialize(app)
    @primary   = SyntageSdk::Webhook::Middleware.new(app, secret: ENV.fetch('SYNTAGE_WEBHOOK_SECRET_NEW'))
    @secondary = SyntageSdk::Webhook::Middleware.new(app, secret: ENV.fetch('SYNTAGE_WEBHOOK_SECRET_OLD'))
  end

  def call(env)
    status, headers, body = @primary.call(env.dup)
    return [status, headers, body] unless status == 401

    @secondary.call(env)
  end
end

config.middleware.use DualSecretWebhookMiddleware
```

3. Once Syntage stops signing with the old secret (or after the 5-minute
   tolerance window has passed for all in-flight requests), remove
   `SYNTAGE_WEBHOOK_SECRET_OLD` and replace the wrapper with the standard
   middleware pointing to `SYNTAGE_WEBHOOK_SECRET_NEW`.

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

### Versioning and releases

This gem follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
(`MAJOR.MINOR.PATCH`). To cut a release:

1. Update `CHANGELOG.md`: move the relevant entries from `[Unreleased]` into
   a new `## [X.Y.Z] - YYYY-MM-DD` section, following
   [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
2. Bump `SyntageSdk::VERSION` in `lib/syntage_sdk/version.rb` to match.
3. Commit both changes, then tag the commit and push the tag:

   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

Pushing a `v*` tag triggers the `Release` workflow
(`.github/workflows/release.yml`), which builds the gem and publishes a
GitHub Release with the `.gem` file attached. The gem is not yet published
to RubyGems.org.
