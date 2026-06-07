# Improvements

This document lists the main areas I would improve next if this project moved beyond the scope of the technical test.

## Index

- [ACL System](#acl-system)
- [Money and Invoicing](#money-and-invoicing)
- [Tax Rates](#tax-rates)
- [Auditing](#auditing)
- [PDF Generation and Sending](#pdf-generation-and-sending)
- [Testing](#testing)
- [UI and UX](#ui-and-ux)
- [Partner Groups](#partner-groups)

## ACL System

- Treat the quote editor as a collaborative tool instead of a strictly personal workspace.
  In this implementation, users belonging to the same organization can already work on the same quotes. This is a deliberate choice: in practice, quote preparation is often shared between several people on the same account, and restricting the index to “only the quotes I created myself” would make collaboration weaker.

- To make that collaborative behavior more complete, introduce a proper access-control layer instead of relying only on the current partner-level rule.
  A good next step would be to add a `Client` model and a `ClientAccess` model so permissions can be defined per user and per client.

- A possible data structure would be:

```rb
# clients
# - id: integer
# - name: string
# - billing_address: string
# - crm_reference: string
# - created_at: datetime
# - updated_at: datetime

# partner_clients
# - id: integer
# - partner_id: integer
# - client_id: integer
# - created_at: datetime
# - updated_at: datetime
#
# This join table expresses that a client can work with multiple partners,
# and a partner can also work with multiple clients.
#
# client_accesses
# - id: integer
# - client_id: integer
# - user_id: integer
# - can_view: boolean
# - can_edit: boolean
# - can_create_quotes: boolean
# - created_at: datetime
# - updated_at: datetime
```

- With that approach:
  - a quote would belong to a client
  - a client could be shared across multiple partners through `partner_clients`
  - a user could access only the clients explicitly granted to them
  - quote visibility and quote edition would no longer be inferred only from partner membership

- Authorization should then be enforced through dedicated policies under a `/policies` folder.
  Example structure:
  - `app/policies/application_policy.rb`
  - `app/policies/client_policy.rb`
  - `app/policies/quote_policy.rb`
  - `app/policies/quote_item_policy.rb`

- Example policy responsibilities:
  - `QuotePolicy#index?`
    - can the user list quotes at all
  - `QuotePolicy#show?`
    - can the user view this quote through the client access
  - `QuotePolicy#create?`
    - can the user create a quote for this client
  - `QuotePolicy#update?`
    - can the user edit this quote
  - `QuotePolicy#destroy?`
    - can the user delete this quote
  - `QuoteItemPolicy#update?`
    - can the user edit items of this quote

- In practical terms, the policy rule could read like:
  - the user must belong to a partner linked to the client
  - the user must have access to the client through `client_accesses`
  - the requested action must be allowed by the `ClientAccess` record
  - and, for some actions, the quote must still be in draft

- A simplified implementation could look like:

```rb
# app/policies/quote_policy.rb
class QuotePolicy < ApplicationPolicy
  def show?
    client_access&.can_view?
  end

  def create?
    client_access&.can_create_quotes?
  end

  def update?
    client_access&.can_edit? && record.in_draft?
  end

  def destroy?
    client_access&.can_edit? && record.in_draft?
  end

  private

  def client_access
    @client_access ||= ClientAccess
      .joins(client: :partner_clients)
      .where(user_id: user.id, client_id: record.client_id)
      .where(partner_clients: { partner_id: user.partner_id })
      .first
  end
end
```

```rb
# app/policies/quote_item_policy.rb
class QuoteItemPolicy < ApplicationPolicy
  def update?
    quote_policy.update?
  end

  def destroy?
    quote_policy.update?
  end

  private

  def quote_policy
    QuotePolicy.new(user, record.quote)
  end
end
```

```rb
# app/controllers/quotes_controller.rb
def show
  @quote = Quote.find(params[:id])
  authorize @quote
end

def update
  @quote = Quote.find(params[:id])
  authorize @quote

  if @quote.update(quote_params)
    # ...
  else
    # ...
  end
end
```

- Good gems to support this kind of policy layer:
  - `pundit`
    - simple, explicit, and very common in Rails applications
  - `action_policy`
    - more feature-rich, with good support for caching and more advanced authorization patterns
  - `cancancan`
    - another popular option, though I would probably prefer `pundit` or `action_policy` here because they keep per-action rules very explicit

- My preference for this project would be `pundit`.
  It would fit the current codebase well because the application already has a small number of business entities and clear controller actions. Policy classes would make the authorization rules easier to read, easier to test, and easier to evolve once collaboration becomes client-based instead of only partner-based.

## Money and Invoicing

- Add real multi-currency support instead of forcing euro formatting in all locales.

- A good product design would be:
  - store a default currency at the partner level
  - store a currency on the client as well
  - snapshot the chosen currency on the quote itself at creation time

- The quote-level currency is important because it freezes the business context of the document.
  Even if the partner or client currency changes later, an existing quote should keep the currency it was created with.

- A possible structure could be:

```rb
# partners
# - id: integer
# - name: string
# - default_currency: string

# clients
# - id: integer
# - name: string
# - default_currency: string

# quotes
# - id: integer
# - client_id: integer
# - currency: string
```

- This also unlocks a realistic edge case for border businesses.
  Example: a partner based in Annemasse may usually work in euros, but may also do business with Swiss companies that expect quotes in CHF.

- In that case, I would adjust the quote creation flow to let the user choose:
  - the partner currency
  - or the client currency

- The UX could be:
  - if partner currency and client currency are the same, skip the currency choice entirely
  - if they differ, show a short currency selection step during quote creation
  - once selected, persist that value on the quote and use it everywhere:
    - display
    - totals
    - PDF
    - email sending

- This keeps the common case smooth while still handling international or border-specific use cases correctly.

## Tax Rates

- In the current implementation, the quote-item form uses a small fixed list of tax-rate options.
  This is a reasonable first step because VAT rates are usually a limited set of legal values rather than arbitrary percentages.

- However, tax rules change over time, and they can also vary depending on the type of business a partner operates.
  Because of that, I would make tax-rate options configurable instead of hardcoding them in the form.

- A good approach would be to store the allowed tax rates in a partner-level configuration object.
  That way:
  - if the law changes, the partner can update the configuration
  - if a partner works in a very specific activity with only one valid tax rate, the interface can be simplified automatically

- A possible structure could be:

```rb
# partners
# - id: integer
# - name: string
# - tax_rate_configuration: json
#
# Example:
# {
#   "allowed_tax_rates": [0, 5.5, 10, 20],
#   "default_tax_rate": 20
# }
```

- Another option would be to use a dedicated model:

```rb
# partner_tax_rates
# - id: integer
# - partner_id: integer
# - value: decimal
# - default: boolean
# - created_at: datetime
# - updated_at: datetime
```

- The form could then read from the partner configuration instead of using hardcoded values.

```rb
current_user.partner.allowed_tax_rates
# => [0, 5.5, 10, 20]
```

- This also improves the user experience.
  For example:
  - if a partner has only one configured tax rate, the form can prefill it and avoid presenting unnecessary choices
  - if a partner has several valid tax rates, the dropdown remains available

- This keeps the UI aligned with legal reality while remaining simple for partners with narrower operational needs.

## Auditing

- Quotes are legally meaningful business documents, so it would be valuable to keep a full history of changes.
  A user should be able to answer questions such as:
  - who changed this quote
  - when was it changed
  - which fields were modified
  - what the previous value was

- A good fit for this in Rails is `paper_trail`.
  It is a well-known gem for model versioning and change history.

- With `paper_trail`, the application could keep versions for:
  - `Quote`
  - `QuoteItem`
  - possibly future models such as `Client`

- This would be especially useful for:
  - validated quotes
  - disputes about prices or quantities
  - support/debugging
  - internal accountability between users of the same organization

- A basic setup could look like:

```rb
# Gemfile
gem "paper_trail"
```

```rb
# app/models/quote.rb
class Quote < ApplicationRecord
  has_paper_trail
end
```

```rb
# app/models/quote_item.rb
class QuoteItem < ApplicationRecord
  has_paper_trail
end
```

- To know who performed a change, the current user should be attached to the version metadata:

```rb
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit
end
```

- Once that is in place, each update creates a version record with:
  - the item type (`Quote`, `QuoteItem`, ...)
  - the item id
  - the event (`create`, `update`, `destroy`)
  - the serialized object before change
  - the user id or username through `whodunnit`

- Reading the history could then look like:

```rb
quote.versions.each do |version|
  puts version.event
  puts version.whodunnit
  puts version.created_at
end
```

- If we want to expose the exact field changes, we could also use:

```rb
quote.versions.last.changeset
# => { "name" => ["Old name", "New name"] }
```

- In a more advanced implementation, I would likely add:
  - a dedicated quote history panel in the UI
  - human-readable audit entries such as:
    - "Kevin Dreno changed quantity from 12 to 15"
    - "Sohaib Haddad validated the quote"
  - selective versioning if some fields should not create noise

- This would improve legal traceability and make the editor safer in a collaborative environment.

## PDF Generation and Sending

- A natural next step for the product would be to generate a PDF version of the quote and let the user send it to the client with a single action.

- This matters because, in practice, a quote editor is rarely the final destination of the data.
  Users usually need:
  - a client-facing PDF
  - a stable document snapshot
  - a way to send the quote directly without leaving the platform

- A possible user flow would be:
  - the user validates the quote
  - clicks `Generate PDF`
  - reviews the final document if needed
  - clicks `Send to client`

- For PDF generation in Rails, possible approaches include:
  - `wicked_pdf`
    - HTML-to-PDF using wkhtmltopdf
  - `grover`
    - HTML-to-PDF using headless Chrome
  - `prawn`
    - pure Ruby PDF generation

- My preference here would probably be `grover` or `wicked_pdf`.
  The current application already renders the quote as HTML, so reusing a dedicated printable HTML template would likely be faster and easier than building the PDF layout manually with `prawn`.

- A possible implementation could look like:

```rb
# app/controllers/quotes_controller.rb
def pdf
  @quote = Quote.find(params[:id])
  authorize @quote

  html = render_to_string(
    template: "quotes/pdf",
    layout: "pdf",
    formats: [:html]
  )

  pdf = Grover.new(html).to_pdf

  send_data pdf,
    filename: "quote-#{@quote.id}.pdf",
    type: "application/pdf",
    disposition: "inline"
end
```

```rb
# config/routes.rb
resources :quotes do
  get :pdf, on: :member
end
```

- Once the PDF exists, sending it to the client could be handled with mailers:

```rb
# app/mailers/quote_mailer.rb
class QuoteMailer < ApplicationMailer
  def send_quote(quote, recipient_email)
    @quote = quote

    attachments["quote-#{quote.id}.pdf"] = quote.generated_pdf.download

    mail(
      to: recipient_email,
      subject: "Your quote #{quote.name}"
    )
  end
end
```

- To make this robust, I would also add:
  - a stored PDF snapshot at the moment of validation
  - background jobs for PDF generation and email sending
  - delivery status tracking
  - a dedicated email body and subject customization
  - protection against sending a draft quote by mistake

- A strong product rule would be:
  - once a quote is validated, the PDF sent to the client should reflect that frozen version of the quote
  - if the business wants to change it later, a new quote version or a new quote should probably be created

- This feature would move the editor closer to a complete operational workflow: prepare, validate, generate, and send.

## Testing

- Add end-to-end system tests for the main Turbo flows:
  - create quote
  - edit quote
  - create quote item
  - edit quote item
  - validate quote
- Add request coverage for locale switching across more screens.
- Add more JavaScript tests around complex UI interactions involving multiple modals or guards.

## UI and UX

- Improve accessibility of modal flows:
  - focus management
  - keyboard escape support
  - focus return after close
- Add loading and disabled states for all Turbo form submissions to make in-flight actions clearer.
- Add optimistic UI hints or subtle row highlighting after create/update actions.

## Partner Groups

- In the spirit of going big rather than staying only at the small-partner level, I would add support for partner groups.

- This would make the product a better fit for large hospitality organizations such as:
  - Accor
  - Ibis
  - or any other group operating multiple brands, properties, or business entities

- The current `Partner` model is a good fit for a single operating entity, but large groups often need an extra level above that.
  For example:
  - one group
  - multiple partners inside the group
  - multiple users attached to each partner

- A possible structure could be:

```rb
# partner_groups
# - id: integer
# - name: string
# - created_at: datetime
# - updated_at: datetime

# partners
# - id: integer
# - partner_group_id: integer
# - name: string
# - default_currency: string
# - created_at: datetime
# - updated_at: datetime
```

- With that structure, the application could support use cases such as:
  - group-wide reporting
  - shared client relationships across several partners of the same group
  - centralized configuration rules
  - easier administration for users working across several entities

- This could also interact well with the previous ACL improvement.
  Access control could then be defined at multiple levels:
  - group level
  - partner level
  - client level

- Some concrete product examples:
  - a large hotel group wants common VAT defaults for all subsidiaries
  - a central sales team wants visibility across multiple brands
  - a client works with several entities inside the same group and expects a consistent experience

- This would move the editor from a partner-only product to something that also scales for enterprise-style account structures.
