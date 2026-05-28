---
type: skill
name: Refactoring
description: Safe code refactoring with step-by-step approach
skillSlug: refactoring
phases: [E]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Ensure test coverage exists in the target service (RSpec, pytest, Go testing, Jest)
2. Identify the specific improvement within one service submodule
3. Check for cross-service impact: shared DB schema, nginx routes, JWT contract
4. Make one type of change at a time, within one service
5. Run the service's test suite after each change
6. Verify API routes still work through gateway: `curl http://localhost:3030/api/v1/...`
7. Commit frequently: `refactor(scope): description`
8. Verify no behavior changes: same inputs produce same outputs

## Examples

**Evo CRM refactoring — extract method in Rails controller:**
```ruby
# Before: Inline logic in CRM tickets controller
# evo-ai-crm-community/app/controllers/api/v1/tickets_controller.rb

def create
  account = Account.find_by!(token: request.headers['Authorization'])
  ticket = Ticket.new(ticket_params)
  ticket.account = account
  ticket.status = 'open'
  if ticket.save
    TicketMailer.notify_agents(ticket).deliver_later
    render json: ticket, status: :created
  else
    render json: { errors: ticket.errors }, status: :unprocessable_entity
  end
end

# After: Extracted service object
# evo-ai-crm-community/app/services/ticket_creator.rb

class TicketCreator
  def initialize(account:, params:)
    @account = account
    @params = params
  end

  def call
    ticket = @account.tickets.new(@params)
    ticket.status = 'open'
    if ticket.save
      TicketMailer.notify_agents(ticket).deliver_later
      { success: true, ticket: ticket }
    else
      { success: false, errors: ticket.errors }
    end
  end
end

# evo-ai-crm-community/app/controllers/api/v1/tickets_controller.rb
def create
  result = TicketCreator.new(
    account: current_account,
    params: ticket_params
  ).call

  if result[:success]
    render json: result[:ticket], status: :created
  else
    render json: { errors: result[:errors] }, status: :unprocessable_entity
  end
end
```

## Quality Bar

- Never refactor without tests in the target service
- One refactoring type per commit, within one service
- Run service-specific tests after each step
- Verify API through gateway after changes to backend services
- Check shared DB schema compatibility if touching models
- Verify nginx routes still resolve correctly if renaming paths
- Don't mix refactoring with feature changes or bug fixes
- If tests break, you changed behavior — revert and reassess

## Resource Strategy

- Use `make shell-<service>` to run tests inside containers
- Use `make logs SERVICE=<name>` after refactoring to check for errors
- Use `curl http://localhost:3030/api/v1/...` for API behavior verification
- Reference service-specific test frameworks: RSpec (Rails), pytest (Python), `go test` (Go), Jest (TS)
