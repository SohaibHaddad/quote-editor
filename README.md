# Quote Editor

This repository contains a Rails 8 quote editor built for the Kactus technical test.

For follow-up product and technical ideas, see [IMPROVEMENTS.md](./IMPROVEMENTS.md).

The application is deployed on Heroku here: https://quote-editor-4a953b05d8b7.herokuapp.com/.
To connect, see the [Demo Logins](#demo-logins) section.
If you want to run the project locally, see the [Setup](#setup) section.

## Index

- [Tech Stack](#tech-stack)
- [Requirements](#requirements)
- [Setup](#setup)
- [Demo Logins](#demo-logins)
- [Running the Application](#running-the-application)
- [Running Tests](#running-tests)
- [Main Functional Rules](#main-functional-rules)
- [Money and Precision](#money-and-precision)
- [Interface Notes](#interface-notes)
- [Project Structure Notes](#project-structure-notes)
- [Authentication](#authentication)
- [Localization](#localization)
- [Notes](#notes)

The application lets partner users:
- sign in with seeded accounts
- list partner quotes
- create, edit, delete, and validate quotes
- manage quote items directly from the quote show page
- view quote totals before tax, tax amount, and after tax

The UI uses Hotwire:
- `Turbo` for inline create, edit, and delete flows
- `Stimulus` for client-side behaviors such as live totals preview and unsaved-changes guards

## Tech Stack

- Ruby on Rails 8.1
- SQLite in development and test
- PostgreSQL in production
- Hotwire (`turbo-rails`, `stimulus-rails`)
- Tailwind CSS
- Devise
- `state_machines-activerecord`
- RSpec + FactoryBot
- Vitest + jsdom for JavaScript tests

## Requirements

- Ruby
- Bundler
- Node.js and npm
- SQLite for local development
- PostgreSQL for production deployments such as Heroku

The project currently uses:
- Rails `8.1.3`
- SQLite via the `sqlite3` gem in development and test
- PostgreSQL via the `pg` gem in production

## Setup

1. Install Ruby dependencies:

```bash
bundle install
```

2. Install JavaScript dependencies:

```bash
npm install
```

3. Create and migrate the database:

```bash
bin/rails db:create db:migrate
```

4. Seed the demo partner, users, quotes, and quote items:

```bash
bin/rails db:seed
```

## Demo Logins

The app does not support sign up from the UI. Users are created through seeds.

Seeded partner:

- `Kactus resort and hotels`

Seeded users usernames:

- `Sohaib Haddad`
- `Kevin Dreno`
- `Benoit Calin`

Shared password for all seeded users:

- `password123`

You can override the shared seed password with:

```bash
SEED_PASSWORD="my-password" \
bin/rails db:seed
```

## Running the Application

Start the Rails server:

```bash
bin/rails server
```

Then open:

```text
http://localhost:3000
```

If `foreman` is installed, you can also run:

```bash
bin/dev
```

This starts:
- the Rails server
- the Tailwind watcher from `Procfile.dev`

## Running Tests

Run the Ruby test suite:

```bash
bundle exec rspec
```

Run the JavaScript test suite:

```bash
npm run test:js
```

## Main Functional Rules

- A quote belongs to a partner and has a creator.
- Quote items belong to a quote.
- Quote item amounts are stored as integer cents in the database to avoid floating-point precision issues.
- A quote can move from `in_draft` to `validated`.
- A quote can only be validated if it has at least one item.
- A validated quote cannot be edited or deleted.
- Quote items of a validated quote cannot be created, updated, or deleted.
- Deleting a quote cascades to its quote items.

## Money and Precision

Money is stored in the database as integer cents through `unit_price_before_tax_in_cents`.

This avoids the classic precision problems of floating-point numbers. Many decimal
values cannot be represented exactly in binary, so apparently simple calculations
can produce unexpected results.

Examples:

```ruby
0.1 + 0.2
# => 0.30000000000000004
```

```ruby
12.34 * 3
# may become 37.019999999999996
```

Those tiny errors become problematic when:
- summing many quote items
- computing VAT
- comparing totals
- formatting invoice-ready amounts

Using integer cents keeps the calculations deterministic:

```ruby
1234 + 250
# => 1484
```

Then the application converts cents back to a decimal amount only for display.

The application also computes quote totals in cents first, instead of summing
already formatted decimal amounts.

This is important because tax calculations can produce fractional cents.

Example:

```ruby
12.34 * 1.20
# => 14.808
```

That amount cannot exist as real money because a price cannot be charged with
`0.8` of a cent.

If the application kept those intermediate decimal values and only rounded at
display time, totals could become inconsistent depending on when rounding is
applied.

This project therefore uses the following approach:
- compute line totals in integer cents
- round tax-inclusive line totals at the line level
- sum the rounded line totals in cents
- convert back to decimal amounts only for display

This makes the behavior predictable and closer to invoice-style expectations.

## Interface Notes

- The quote index is the home page.
- Quote creation and edition happen inline in the table with Turbo Stream.
- Quote item creation and edition happen inline in the quote show table with Turbo Stream.
- The app includes custom modals for destructive actions and unsaved inline changes.
- The application supports English and French, with French as the default locale.

## Project Structure Notes

- `app/models`
  Domain rules, totals, validations, and state machine logic.
- `app/controllers`
  Turbo-oriented CRUD flows for quotes and quote items.
- `app/views/quotes`
  Quote index and show screens.
- `app/views/quote_items`
  Inline quote item table, forms, and Turbo Stream responses.
- `app/javascript/controllers`
  Stimulus controllers for delete confirmation, live totals preview, and unsaved-changes guards.

## Authentication

Authentication is handled by Devise.

Current scope:
- login only
- no sign up UI
- all application pages require authentication

## Localization

The app currently provides:
- French translations in `config/locales/fr.yml`
- English translations in `config/locales/en.yml`

French is the default locale.

## Notes

- Currency display is currently forced to euro in both locales.
- The application uses SQLite locally and PostgreSQL in production.
- The codebase includes both Ruby and JavaScript automated tests.
