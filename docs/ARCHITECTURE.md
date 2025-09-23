# HousekeepingBook - Technical Architecture

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  Phoenix LiveView │ Components │ Templates │ Storybook      │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│  Controllers │ LiveView Modules │ Channels │ Router         │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                       Domain Layer                           │
│  Accounts Domain │ Households Domain │ Business Logic       │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    Data Access Layer                         │
│  Ash Resources │ Ecto Schemas │ Queries │ Migrations        │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                       │
│  PostgreSQL │ Repo │ Mailer │ PubSub │ Telemetry           │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Core Framework

- **Phoenix Framework 1.7.10**: Web application framework
- **Elixir 1.14+**: Functional programming language
- **Erlang/OTP 25+**: Runtime system

### Data Layer

- **Ash Framework 3.0**: Domain modeling and API framework
- **AshPostgres 2.0**: PostgreSQL adapter for Ash
- **Ecto 3.10**: Database wrapper and query generator
- **PostgreSQL**: Primary database

### Authentication & Security

- **Ash Authentication 4.1**: Authentication framework
- **Ash Authentication Phoenix 2.0**: Phoenix integration
- **BCrypt**: Password hashing
- **Guardian/Joken**: JWT token handling

### Frontend Technologies

- **Phoenix LiveView 0.20.1**: Real-time server-rendered UI
- **Tailwind CSS 3.3.2**: Utility-first CSS framework
- **ESBuild 0.17.11**: JavaScript bundler
- **Phoenix Storybook 0.6.0**: Component development environment

### Development Tools

- **Credo 1.7**: Static code analysis
- **Dialyxir 1.0**: Static type checking
- **Boundary 0.10**: Dependency enforcement
- **ExUnit**: Testing framework

### Infrastructure

- **Bandit 1.0**: HTTP server
- **Swoosh 1.3**: Email composition and delivery
- **Finch 0.13**: HTTP client
- **Site Encrypt**: Let's Encrypt integration

### Internationalization

- **ex_cldr 2.37**: Unicode CLDR implementation
- **ex_cldr_numbers**: Number localization
- **ex_cldr_dates_times**: Date/time localization
- **Gettext 0.20**: Internationalization

## Architectural Patterns

### 1. Domain-Driven Design (DDD)

The application follows DDD principles with clear bounded contexts:

```elixir
# Bounded Contexts
HousekeepingBook.Accounts     # User management domain
HousekeepingBook.Households   # Financial tracking domain
HousekeepingBook.RecordsImporter # Import functionality
```

### 2. Hexagonal Architecture (Ports & Adapters)

```
External World ← Adapters → Ports → Application Core
                    │          │            │
              Web Requests  Interfaces  Domain Logic
```

### 3. CQRS Pattern

Commands and Queries are separated in Ash resources:

```elixir
# Commands (Write)
- create_record
- update_record
- delete_record

# Queries (Read)
- monthly_records
- get_record
- amount_by_day_and_type
```

### 4. Repository Pattern

Ash Resources abstract data access:

```elixir
# Instead of direct Repo calls
Repo.get(Record, id)

# Use Ash abstraction
Households.get_record!(id)
```

### 5. Event-Driven Updates

LiveView provides real-time updates through Phoenix PubSub:

```
User Action → LiveView Process → PubSub Broadcast → UI Update
```

## Domain Model

### Accounts Domain

```
User
├── id: integer (PK)
├── email: string
├── hashed_password: string
├── confirmed_at: datetime
├── type: enum (normal, shared)
└── Relationships
    ├── has_many :tokens
    └── has_many :records (through subject)

UserToken
├── id: integer (PK)
├── user_id: integer (FK)
├── token: binary
├── context: string
└── sent_to: string
```

### Households Domain

```
Record
├── id: integer (PK)
├── date: datetime
├── amount: integer
├── description: string
├── payment: enum
├── subject_id: integer (FK)
├── category_id: integer (FK)
└── Relationships
    ├── belongs_to :subject (User)
    ├── belongs_to :category
    └── many_to_many :tags

Category (Hierarchical)
├── id: integer (PK)
├── name: string
├── type: enum (expense, income, saving)
├── parent_id: integer (FK, self-reference)
└── Relationships
    ├── belongs_to :parent (Category)
    ├── has_many :children (Category)
    └── has_many :records

Tag
├── id: integer (PK)
├── name: string
└── Relationships
    └── many_to_many :records

RecordTag (Join Table)
├── record_id: integer (FK)
└── tag_id: integer (FK)
```

## Data Flow Architecture

### Request Lifecycle

```
1. HTTP Request → Phoenix Router
2. Router → Controller/LiveView
3. Controller → Domain Context
4. Domain → Ash Resource
5. Ash Resource → PostgreSQL
6. Response → JSON/HTML/LiveView
```

### LiveView Data Flow

```
1. WebSocket Connection
2. Mount Lifecycle
3. Handle Events
4. Update State
5. Render Diff
6. Send to Client
```

## Security Architecture

### Authentication Flow

```
Registration/Login
       ↓
Generate Token
       ↓
Store in Session
       ↓
Verify on Request
       ↓
Authorize Action
```

### Security Layers

1. **Network Security**
   - HTTPS/TLS encryption
   - CORS policies
   - Rate limiting

2. **Application Security**
   - CSRF protection
   - SQL injection prevention (Ecto)
   - XSS protection
   - Input validation

3. **Data Security**
   - Password hashing (BCrypt)
   - Token expiration
   - Environment-based secrets

## Deployment Architecture

### Production Environment

```
Internet → Load Balancer
              ↓
         Phoenix App
              ↓
         PostgreSQL
```

### Configuration Management

- Development: `config/dev.exs`
- Test: `config/test.exs`
- Production: `config/runtime.exs` + Environment Variables

### Release Strategy

1. Mix Release compilation
2. Distillery/Release packaging
3. Zero-downtime deployment
4. Database migrations
5. Asset compilation and CDN

## Performance Architecture

### Optimization Strategies

1. **Database Performance**
   - Indexed queries
   - Connection pooling
   - Prepared statements
   - Query optimization

2. **Application Performance**
   - ETS caching
   - Process pooling
   - Lazy loading
   - Pagination (keyset-based)

3. **Frontend Performance**
   - LiveView DOM diffing
   - Asset fingerprinting
   - CDN distribution
   - Compression

### Scalability Patterns

1. **Horizontal Scaling**
   - Stateless application design
   - Session storage in database
   - Distributed Erlang clustering

2. **Vertical Scaling**
   - Process optimization
   - Memory management
   - Connection pooling

## Monitoring & Observability

### Telemetry Integration

```elixir
- Phoenix.Telemetry
- Ecto.Telemetry
- LiveView.Telemetry
```

### Metrics Collection

- Request duration
- Database query time
- LiveView mount time
- Error rates
- Resource usage

## Development Architecture

### Project Structure

```
housekeeping_book/
├── lib/
│   ├── housekeeping_book/        # Business logic
│   │   ├── accounts/             # Accounts domain
│   │   ├── households/           # Households domain
│   │   └── application.ex        # OTP application
│   └── housekeeping_book_web/    # Web layer
│       ├── components/           # Reusable UI components
│       ├── controllers/          # HTTP controllers
│       ├── live/                 # LiveView modules
│       └── router.ex             # Routing
├── priv/
│   ├── repo/                     # Database migrations
│   └── static/                   # Static assets
├── test/                         # Test files
├── assets/                       # Frontend assets
└── config/                       # Configuration
```

### Module Dependencies

Using Boundary library for dependency enforcement:

```
Application
    ↓
HousekeepingBookWeb ← HousekeepingBook
    ↓                      ↓
Controllers/LiveView   Domains
    ↓                      ↓
Components            Resources
                          ↓
                        Repo
```
