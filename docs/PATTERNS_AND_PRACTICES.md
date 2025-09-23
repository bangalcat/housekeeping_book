# HousekeepingBook - Patterns and Best Practices

## Architectural Patterns

### 1. Domain-Driven Design (DDD)

**Implementation**:

```elixir
# Clear bounded contexts
defmodule HousekeepingBook.Households do
  use Ash.Domain

  resources do
    resource Record
    resource Category
    resource Tag
  end
end
```

**Benefits**:

- Clear separation of business concerns
- Ubiquitous language within domains
- Reduced coupling between domains
- Easier to reason about complex business logic

### 2. Action-Based Operations (Ash Framework Pattern)

**Implementation**:

```elixir
# Write Operations
actions do
  create :create do
    accept [:date, :amount, :description]
  end

  update :update do
    accept [:date, :amount, :description]
  end
end

# Read Operations
actions do
  read :monthly_records do
    argument :date_month, :term
    prepare HousekeepingBook.Households.Preparations.DateMonthFilter
  end

  read :amount_by_day_and_type do
    prepare build(load: [:day, :category_type, :daily_amount])
  end
end
```

**Benefits**:

- Clear separation of operations by intent
- Declarative action definitions
- Built-in validations and authorization
- Easier to add custom preparations and filters

**Note**: While Ash separates read and write actions, this is not true CQRS as it doesn't implement separate models for commands and queries

### 3. Repository Pattern

**Implementation**:

```elixir
# Instead of direct database access
Repo.get(Record, id)

# Use domain abstraction
HousekeepingBook.Households.get_record!(id)
```

**Benefits**:

- Abstraction over data access
- Testability through mocking
- Centralized query logic
- Easy to switch data sources

### 4. Hexagonal Architecture (Ports & Adapters)

**Structure**:

```
Adapters (Web, CLI) → Ports (Interfaces) → Application Core
```

**Implementation**:

- Ash resources as ports
- Phoenix controllers/LiveView as adapters
- Domain logic independent of delivery mechanism

**Benefits**:

- Testable business logic
- Multiple delivery mechanisms
- Clear separation of concerns
- Technology independence

### 5. Event-Driven Architecture

**Implementation**:

```elixir
# LiveView real-time updates
def handle_info({:record_created, record}, socket) do
  {:noreply, stream_insert(socket, :records, record)}
end
```

**Benefits**:

- Real-time updates
- Loose coupling
- Scalability
- Audit trail capability

## Design Patterns

### 1. Builder Pattern (Ash Actions)

**Implementation**:

```elixir
read :monthly_records do
  argument :date_month, :term
  prepare DateMonthFilter
  prepare build(sort: [date: :desc])
  prepare build(load: [:subject, :category, :tags])
end
```

### 2. Strategy Pattern (Payment Types)

**Implementation**:

```elixir
defmodule HousekeepingBook.Households.PaymentType do
  use Ash.Type.Enum, values: [:card, :cash, :transfer, :other]

  def description(:card), do: "Credit/Debit Card"
  def description(:cash), do: "Cash"
  def description(:transfer), do: "Bank Transfer"
  def description(:other), do: "Other"
end
```

### 3. Composite Pattern (Category Hierarchy)

**Implementation**:

```elixir
relationships do
  belongs_to :parent, __MODULE__
  has_many :children, __MODULE__, destination_attribute: :parent_id
end
```

### 4. Factory Pattern (Fixtures)

**Implementation**:

```elixir
def user_fixture(attrs \\ %{}) do
  {:ok, user} =
    attrs
    |> Enum.into(@valid_attrs)
    |> Accounts.create_user()
  user
end
```

## Phoenix-Specific Patterns

### 1. LiveView Lifecycle Management

**Pattern**:

```elixir
def mount(_params, session, socket) do
  socket = assign_user_device(socket, session)
  {:ok, assign_defaults(socket)}
end

def handle_params(params, _url, socket) do
  {:noreply, apply_action(socket, socket.assigns.live_action, params)}
end

defp apply_action(socket, :index, params) do
  socket
  |> assign_list_records(params)
  |> assign(:page_title, "Listing Records")
end
```

### 2. Stream-Based Updates

**Pattern**:

```elixir
# Efficient DOM updates
stream(:records, records, reset: true)
stream_insert(socket, :records, record)
stream_delete(socket, :records, record)
```

### 3. Component Composition

**Pattern**:

```elixir
defmodule CoreComponents do
  use Phoenix.Component

  attr :label, :string, required: true
  attr :value, :any

  def data_list(assigns) do
    ~H"""
    <div class="data-list">
      <dt><%= @label %></dt>
      <dd><%= @value %></dd>
    </div>
    """
  end
end
```

## Ash Framework Patterns

### 1. Declarative Actions

**Pattern**:

```elixir
actions do
  defaults [:read, :destroy]

  create :create do
    accept [:date, :amount, :description]
    require_attributes [:date, :category_id]
  end
end
```

### 2. Calculations

**Pattern**:

```elixir
calculations do
  calculate :daily_amount, :map,
    expr(%{day: day(timezone: arg(:timezone)), type: category_type})

  calculate :category_type, CategoryType,
    expr(category.type)
end
```

### 3. Preparations

**Pattern**:

```elixir
prepare fn query, _context ->
  date = Ash.Query.get_argument(query, :date)
  Ash.Query.filter(query, date > ^start_date and date <= ^end_date)
end
```

## Database Patterns

### 1. Soft Deletes Alternative

**Pattern**: Use `on_delete: :nilify` instead of soft deletes

```elixir
references do
  reference :category, on_delete: :nilify
end
```

### 2. Keyset Pagination

**Pattern**:

```elixir
pagination do
  keyset? true
  default_limit 1000
end
```

### 3. Timezone-Aware Queries

**Pattern**:

```elixir
fragment(
  "(date_trunc('day', ? AT TIME ZONE 'Z' AT TIME ZONE ?))",
  date,
  ^timezone
)
```

## Testing Patterns

### 1. DataCase Pattern

**Pattern**:

```elixir
defmodule HousekeepingBook.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto.Query
      import HousekeepingBook.DataCase
    end
  end

  setup tags do
    HousekeepingBook.DataCase.setup_sandbox(tags)
    :ok
  end
end
```

### 2. Fixture Pattern

**Pattern**:

```elixir
def category_fixture(attrs \\ %{}) do
  {:ok, category} =
    attrs
    |> Enum.into(%{name: "Food", type: :expense})
    |> Households.create_category()
  category
end
```

### 3. LiveView Testing

**Pattern**:

```elixir
test "lists all records", %{conn: conn} do
  {:ok, _index_live, html} = live(conn, ~p"/records")
  assert html =~ "Listing Records"
end
```

## Security Best Practices

### 1. Authentication Hooks

**Pattern**:

```elixir
on_mount {HousekeepingBookWeb.LiveUserAuth, :live_user_required}
```

### 2. Input Validation

**Pattern**:

```elixir
validate attribute_does_not_equal(:parent_id, ref(:id))
```

### 3. Environment-Based Configuration

**Pattern**:

```elixir
config :housekeeping_book, HousekeepingBook.Repo,
  username: System.get_env("DB_USER", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres")
```

## Performance Patterns

### 1. Eager Loading

**Pattern**:

```elixir
prepare build(load: [:subject, :category, :tags])
```

### 2. Query Optimization

**Pattern**:

```elixir
|> join(:left, [r], c in assoc(r, :category))
|> group_by([r, c], [selected_as(:day), c.type])
|> exclude(:order_by)
```

### 3. Caching Strategy

**Pattern**:

```elixir
def category_type_options do
  # Cache in module attribute or ETS
  CategoryType.values()
  |> Enum.map(&{CategoryType.category_type_name(&1), &1})
end
```

## Code Organization Best Practices

### 1. Module Naming

**Convention**:

```
HousekeepingBook           # Root namespace
├── Accounts              # Domain
│   ├── User             # Resource
│   └── UserToken        # Resource
└── Households           # Domain
    ├── Record          # Resource
    ├── Category        # Resource
    └── Tag            # Resource
```

### 2. File Structure

**Convention**:

```
lib/
├── housekeeping_book/      # Business logic
│   ├── accounts/          # Domain modules
│   └── households/        # Domain modules
└── housekeeping_book_web/  # Web layer
    ├── components/        # Reusable components
    ├── live/             # LiveView modules
    └── controllers/      # HTTP controllers
```

### 3. Function Naming

**Convention**:

- Public functions: descriptive names (`get_record_by_id`)
- Private functions: prefix with underscore or `do_` (`do_calculate`)
- Predicates: end with `?` (`leaf_category?`)
- Dangerous operations: end with `!` (`delete_record!`)

## Anti-Patterns to Avoid

### 1. God Modules

**Avoid**: Large modules with too many responsibilities
**Instead**: Split into focused modules with single responsibilities

### 2. Anemic Domain Model

**Avoid**: Domain models with only data, no behavior
**Instead**: Rich domain models with business logic

### 3. Circular Dependencies

**Avoid**: Modules depending on each other
**Instead**: Use dependency injection or events

### 4. Magic Numbers/Strings

**Avoid**: Hardcoded values throughout code
**Instead**: Use module attributes or configuration

### 5. Callback Hell

**Avoid**: Deeply nested callbacks
**Instead**: Use with statements or pipeline operator

## Development Workflow Best Practices

### 1. Database Migrations

**Practice**:

```elixir
# Always include rollback logic
def up do
  create table(:records) do
    add :amount, :integer
  end
end

def down do
  drop table(:records)
end
```

### 2. Configuration Management

**Practice**:

- Use `config/runtime.exs` for production
- Environment variables for secrets
- Document all configuration options

### 3. Error Handling

**Practice**:

```elixir
case Households.create_record(attrs) do
  {:ok, record} ->
    {:noreply, socket |> put_flash(:info, "Record created")}
  {:error, changeset} ->
    {:noreply, socket |> assign(:changeset, changeset)}
end
```

### 4. Logging

**Practice**:

```elixir
Logger.info("Record created", record_id: record.id, user_id: user.id)
Logger.error("Failed to create record", error: inspect(error))
```

## Continuous Improvement Practices

### 1. Code Review Checklist

- [ ] Follows naming conventions
- [ ] Has appropriate tests
- [ ] Handles error cases
- [ ] Includes documentation
- [ ] No security vulnerabilities
- [ ] Performance considered
- [ ] Follows SOLID principles

### 2. Refactoring Triggers

- Duplicate code appears 3+ times
- Module exceeds 200 lines
- Function exceeds 20 lines
- Cyclomatic complexity > 7
- Test setup becomes complex

### 3. Technical Debt Management

- Document debt in code comments
- Create issues for significant debt
- Allocate 20% time for debt reduction
- Prioritize debt by impact

## Monitoring and Observability

### 1. Telemetry Events

**Practice**:

```elixir
:telemetry.execute(
  [:housekeeping_book, :record, :created],
  %{duration: duration},
  %{user_id: user_id, category_id: category_id}
)
```

### 2. Health Checks

**Practice**:

```elixir
def health_check do
  %{
    database: check_database(),
    cache: check_cache(),
    version: Application.spec(:housekeeping_book, :vsn)
  }
end
```

