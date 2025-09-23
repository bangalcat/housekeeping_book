# HousekeepingBook - Domain Boundaries

## Domain-Driven Design Implementation

The application implements Domain-Driven Design using the Boundary library to enforce clear separation of concerns and dependencies between modules.

## Core Domains

### 1. Accounts Domain (`HousekeepingBook.Accounts`)

**Purpose**: User management, authentication, and authorization

**Boundary Configuration**:

```elixir
use Boundary,
  deps: [HousekeepingBook.Repo, HousekeepingBook.Schema, HousekeepingBook.Mailer],
  exports: [User, UserToken, WebPaths]
```

**Resources**:

- `User`: User accounts with authentication
- `UserToken`: Authentication tokens
- `Token`: JWT tokens for API access

**Public Interface** (via Ash Domain):

```elixir
# User Management
- get_user_by_id/1
- list_users/0
- create_user/1
- update_user/2
- delete_user/1

# Authentication
- register_user_with_password/1
- update_user_email/2
- update_user_password/3

# Special Users
- create_shared_user/1
```

**Dependencies**:

- `HousekeepingBook.Repo`: Data persistence
- `HousekeepingBook.Schema`: Shared schema definitions
- `HousekeepingBook.Mailer`: Email notifications

**Responsibilities**:

- User lifecycle management
- Password authentication
- Email confirmation
- Token generation and validation
- User type management (normal vs shared)

### 2. Households Domain (`HousekeepingBook.Households`)

**Purpose**: Core financial tracking and categorization logic

**Boundary Configuration**:

```elixir
use Boundary,
  deps: [HousekeepingBook.Repo],
  exports: [Record, Subject, Category, Tag]
```

**Resources**:

- `Record`: Financial transactions
- `Category`: Hierarchical categorization
- `Tag`: Flexible labeling
- `Subject`: Transaction owner
- `RecordTag`: Join table for many-to-many

**Public Interface** (via Ash Domain):

```elixir
# Record Operations
- monthly_records/2
- get_record/1
- get_nearest_date_record/2
- get_record_amount_by_day_and_type/2
- create_record/1
- update_record/2
- delete_record/1

# Category Operations
- get_category_by_name_and_type/2
- get_category/1
- top_categories/0
- child_categories/1
- bottom_categories/0
- list_categories/0
- create_category/1
- update_category/2
- delete_category/1

# Tag Operations
- list_tags/0
- get_tag_by_id/1
- create_tag/1
- update_tag/2
- delete_tag/1

# Domain Logic
- leaf_category?/1
- get_records_amount_sum_group_by_date_and_type/2
- with_total/1
- cast_datetime_with_timezone/2
- category_type_options/0
- record_payment_options/0
```

**Dependencies**:

- `HousekeepingBook.Repo`: Data persistence only

**Responsibilities**:

- Financial record CRUD operations
- Hierarchical category management
- Tag-based organization
- Time-based aggregations
- Timezone-aware date handling
- Payment type management

### 3. Records Importer (`HousekeepingBook.RecordsImporter`)

**Purpose**: Bulk data import functionality

**Boundary Configuration**:

```elixir
use Boundary,
  deps: [HousekeepingBook.Accounts, HousekeepingBook.Households],
  exports: :all
```

**Modules**:

- `CsvImporter`: CSV file processing and import

**Public Interface**:

```elixir
- import_records/2
- my_mapper/1
```

**Dependencies**:

- `HousekeepingBook.Accounts`: User lookup
- `HousekeepingBook.Households`: Record and category creation

**Responsibilities**:

- Parse CSV files
- Map CSV fields to domain models
- Validate import data
- Create records in bulk
- Handle import errors

## Supporting Modules

### 4. Repository (`HousekeepingBook.Repo`)

**Purpose**: Database connection and query execution

**Boundary Configuration**:

```elixir
use Boundary, deps: []
```

**Characteristics**:

- No dependencies (foundational module)
- Used by all domains
- PostgreSQL adapter configuration
- Connection pooling

### 5. Mailer (`HousekeepingBook.Mailer`)

**Purpose**: Email delivery infrastructure

**Boundary Configuration**:

```elixir
use Boundary, deps: []
```

**Characteristics**:

- No dependencies
- Swoosh adapter configuration
- Used by Accounts domain

### 6. Schema (`HousekeepingBook.Schema`)

**Purpose**: Shared schema definitions

**Boundary Configuration**:

```elixir
use Boundary,
  deps: [],
  exports: [User, UserToken]
```

**Characteristics**:

- Legacy schema definitions
- Being migrated to Ash resources
- Provides backward compatibility

### 7. Application (`HousekeepingBook.Application`)

**Purpose**: OTP application supervisor

**Boundary Configuration**:

```elixir
use Boundary,
  top_level?: true,
  deps: [HousekeepingBook, HousekeepingBookWeb]
```

**Characteristics**:

- Top-level module
- Starts all application services
- Configures supervision tree

### 8. CLDR (`HousekeepingBook.Cldr`)

**Purpose**: Internationalization and localization

**Boundary Configuration**:

```elixir
use Boundary,
  top_level?: true,
  deps: [HousekeepingBook],
  exports: [Number, DateTime, Date]
```

**Characteristics**:

- Unicode CLDR implementation
- Number formatting
- Date/time localization
- Currency support

## Web Layer Boundaries

### 9. HousekeepingBookWeb

**Purpose**: Web interface and API

**Boundary Configuration**:

```elixir
use Boundary,
  deps: [HousekeepingBook, HousekeepingBookWeb.Gettext],
  exports: [Endpoint, Gettext, Router, Telemetry]
```

**Submodules**:

- `Controllers`: HTTP request handlers
- `Live`: LiveView modules
- `Components`: Reusable UI components
- `Router`: Request routing
- `Endpoint`: Phoenix endpoint

**Characteristics**:

- Depends on business domains
- Provides web interface
- Real-time LiveView updates
- Component-based UI

## Dependency Rules

### Allowed Dependencies

```
Application
    ├── HousekeepingBook
    │   ├── Accounts
    │   │   ├── Repo
    │   │   ├── Schema
    │   │   └── Mailer
    │   ├── Households
    │   │   └── Repo
    │   └── RecordsImporter
    │       ├── Accounts
    │       └── Households
    └── HousekeepingBookWeb
        └── HousekeepingBook
```

### Forbidden Dependencies

1. **Domain Isolation**: Households ↛ Accounts
2. **Repository Isolation**: Repo ↛ Any domain
3. **Mailer Isolation**: Mailer ↛ Any domain
4. **Web to Domain Only**: Controllers/LiveView ↛ Repo directly

## Domain Events and Communication

### Inter-Domain Communication

Domains communicate through:

1. **Public Interfaces**: Defined functions in domain modules
2. **Ash Actions**: Declarative action definitions
3. **PubSub Events**: For real-time updates

### Event Flow Example

```
User creates record in LiveView
    ↓
LiveView calls Households.create_record/1
    ↓
Households domain validates and persists
    ↓
PubSub broadcasts record_created event
    ↓
Other LiveView processes update UI
```

## Anti-Corruption Layer

### External Integration Points

1. **CSV Import**: RecordsImporter acts as anti-corruption layer
2. **Email Delivery**: Mailer abstracts email provider
3. **Authentication**: Ash Authentication provides abstraction

### Data Transformation

```elixir
External Format → Anti-Corruption Layer → Domain Model
      CSV       →    CsvImporter       →    Record
```

## Bounded Context Map

```
┌─────────────────┐     ┌─────────────────┐
│    Accounts     │────▶│   Households    │
│    Context      │     │    Context      │
└─────────────────┘     └─────────────────┘
        ▲                        ▲
        │                        │
        └────────┬───────────────┘
                 │
         ┌───────────────┐
         │    Importer   │
         │    Context    │
         └───────────────┘
```

### Context Relationships

- **Accounts → Households**: Shared Kernel (User as Subject)
- **Importer → Accounts**: Customer/Supplier
- **Importer → Households**: Customer/Supplier
- **Web → All Domains**: Conformist

## Domain Invariants

### Accounts Domain

1. Email must be unique
2. Password must be hashed
3. Shared users have type :shared

### Households Domain

1. Record must have category and subject
2. Category cannot be its own parent
3. Category type must be expense, income, or saving
4. Amount stored as integers (cents)

### Business Rules Enforcement

Rules are enforced at multiple levels:

1. **Ash Validations**: Declarative validation rules
2. **Database Constraints**: Foreign keys, unique indexes
3. **Domain Logic**: Custom validation functions

## Evolution Strategy

### Current State

- Clear domain boundaries established
- Ash Framework adoption in progress
- Legacy schemas being migrated

### Future Directions

1. **Event Sourcing**: Consider for audit trail
2. **CQRS Expansion**: Separate read models
3. **Microservices**: Potential extraction points identified
4. **API Gateway**: For external integrations

## Testing Boundaries

### Unit Testing

- Test domains in isolation
- Mock external dependencies
- Focus on domain logic

### Integration Testing

- Test across domain boundaries
- Use real database connections
- Verify domain interactions

### End-to-End Testing

- Test complete user workflows
- Include all domains
- Verify system behavior

