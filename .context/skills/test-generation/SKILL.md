---
type: skill
name: Test Generation
description: Generate comprehensive test cases for code
skillSlug: test-generation
phases: [E, V]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Identify the target service and its test framework: RSpec (Rails), pytest (Python), Go testing (Go), Jest/Vitest (TS)
2. Follow the service's existing test file conventions and directory structure
3. Write happy path tests for the primary functionality
4. Add edge case tests: empty inputs, nil/null, boundary values, large payloads
5. Include error handling tests: invalid auth, missing params, DB failures, timeouts
6. Mock external dependencies: WhatsApp API, AI providers, other services
7. For integration tests, test through Nginx Gateway (port 3030)
8. Verify tests pass in the service's environment

## Examples

**RSpec test for CRM tickets controller (evo-ai-crm-community):**
```ruby
# spec/requests/api/v1/tickets_controller_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::TicketsController', type: :request do
  let(:account) { create(:account) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:token) { JwtService.encode(user_id: agent.id, account_id: account.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/tickets' do
    it 'returns paginated tickets for the account' do
      create_list(:ticket, 25, account: account)
      get '/api/v1/tickets', headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['data'].size).to eq(20) # default per_page
      expect(json['meta']['total']).to eq(25)
    end

    it 'returns empty data when no tickets exist' do
      get '/api/v1/tickets', headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['data']).to be_empty
    end

    it 'returns 401 without authentication' do
      get '/api/v1/tickets'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not return tickets from other accounts' do
      other_ticket = create(:ticket) # different account
      get '/api/v1/tickets', headers: headers
      ids = json['data'].map { |t| t['id'] }
      expect(ids).not_to include(other_ticket.id)
    end
  end
end
```

**pytest for processor service (evo-ai-processor-community):**
```python
# tests/test_chat_service.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_create_chat_session_success(auth_headers):
    response = client.post(
        "/api/v1/chat/sessions",
        json={"agent_id": "ag_123", "message": "Hello"},
        headers=auth_headers
    )
    assert response.status_code == 201
    data = response.json()
    assert "session_id" in data
    assert data["status"] == "active"

def test_create_chat_session_no_auth():
    response = client.post(
        "/api/v1/chat/sessions",
        json={"agent_id": "ag_123", "message": "Hello"}
    )
    assert response.status_code == 401

def test_create_chat_session_invalid_agent(auth_headers):
    response = client.post(
        "/api/v1/chat/sessions",
        json={"agent_id": "nonexistent", "message": "Hello"},
        headers=auth_headers
    )
    assert response.status_code == 404
```

## Quality Bar

- Use the correct test framework for the service (RSpec for Rails, pytest for Python, Go testing for Go, Jest for TS)
- Follow existing test conventions: file naming, directory structure, factory/fixture patterns
- Test behavior, not implementation details
- Use descriptive test names: "returns 401 without authentication"
- Follow Arrange-Act-Assert pattern
- Keep tests independent and isolated (no shared state)
- Mock external dependencies at the boundary (WhatsApp, AI providers, other services)
- Test through Nginx Gateway for integration tests (port 3030)
- Include regression tests for bug fixes
- Verify tests pass: `make shell-<service>` or `docker compose exec <service> <test command>`

## Resource Strategy

- Ruby tests: use FactoryBot factories, RSpec conventions in `spec/` directory
- Python tests: use pytest fixtures in `tests/` directory, TestClient for FastAPI
- Go tests: use table-driven tests in `*_test.go` files alongside source
- TypeScript tests: Jest/Vitest in `__tests__/` or alongside components
- Integration tests: use gateway on port 3030 for cross-service testing
- Reference `.context/docs/testing-strategy.md` for framework-specific commands
