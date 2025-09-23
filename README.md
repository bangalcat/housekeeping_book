# HousekeepingBook

> ⚠️ **Development Status**: Learning project for exploring Elixir/Phoenix patterns. Not production-ready.

A multi-user expense tracking application built with Phoenix LiveView and Ash Framework, demonstrating modern Elixir architectural patterns and domain-driven design principles.

## 🎯 Project Purpose

**Learning Focus:**

- Phoenix LiveView 0.20.1 - Real-time server-rendered UI without JavaScript
- Ash Framework 3.0 - Declarative domain modeling and resource management
- Domain-Driven Design - Clear bounded contexts with enforced boundaries
- Modern Patterns - Repository pattern, Hexagonal Architecture

**Core Functionality:**

- Multi-user expense tracking with shared access
- Hierarchical category system with tree structures
- Flexible tagging for enhanced organization
- Monthly/yearly reporting and analytics
- CSV import/export capabilities

## 🏗️ Architecture

### Tech Stack

- **Framework**: Phoenix 1.7.10 with LiveView
- **Domain Layer**: Ash Framework 3.0
- **Database**: PostgreSQL with Ecto
- **Authentication**: Ash Authentication with BCrypt
- **Styling**: Tailwind CSS
- **Testing**: ExUnit (~40% coverage)

### Domain Structure

```
lib/housekeeping_book/
├── accounts/          # User management domain
│   ├── user.ex       # Ash resource
│   └── user_token.ex # Token management
├── households/        # Financial tracking domain
│   ├── record.ex     # Transaction records
│   ├── category.ex   # Hierarchical categories
│   └── tag.ex        # Flexible tagging
└── infrastructure/    # Cross-cutting concerns
```

## 📱 Application Features

### Dashboard

- Financial overview with balance, income, and expense totals
- Recent transaction history (10 most recent)
- Daily expense visualization
- Top 5 spending categories
- Real-time updates via Phoenix LiveView

### Record Management

- **List View**: Calendar-based navigation with daily transaction highlights
- **CRUD Operations**: Create, read, update, delete financial records
- **Search & Filter**: Tag-based search and category filtering
- **Import/Export**: CSV file support for bulk operations
- **Pagination**: Keyset-based pagination for large datasets

### Reporting

- **Monthly Reports**:
  - Selectable month view
  - Income/expense breakdown
  - Daily aggregation views
- **Yearly Reports**:
  - Annual financial summary
  - Category-based analytics
  - Trend visualization

### Navigation Structure

- Home (Dashboard)
- Records
- Monthly Reports
- Yearly Reports

## 📊 Data Model

### Core Entities

| Entity       | Purpose                               | Key Relationships                        |
| ------------ | ------------------------------------- | ---------------------------------------- |
| **User**     | Account management and authentication | Has many Records                         |
| **Record**   | Financial transaction entries         | Belongs to User, Category; Has many Tags |
| **Category** | Hierarchical classification system    | Self-referential tree structure          |
| **Tag**      | Flexible labeling system              | Many-to-many with Records                |

### Schema Details

**User**: Authentication and multi-user support

- Ash Authentication integration
- Normal and shared account types
- Token-based session management

**Category**: Tree-structured classification

- Types: expense, income, saving
- Parent-child relationships
- Hierarchical organization

**Record**: Transaction tracking

- Payment types: card, cash, transfer, other
- Timezone-aware date handling
- Tag-based organization

**Tag**: Flexible labeling system

- Simple name-based tags
- Many-to-many relationship with records
- Enhanced search and filtering capabilities

## 🚀 Getting Started

### Prerequisites

- Elixir 1.14+
- Erlang/OTP 25+
- PostgreSQL 13+
- Node.js 18+ (for assets)

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/housekeeping_book.git
cd housekeeping_book

# Install dependencies
mix deps.get
mix assets.setup

# Setup database
mix ecto.setup

# Start Phoenix server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) to access the application.

## 📁 Project Documentation

Detailed documentation available in `/docs`:

- **ARCHITECTURE.md** - System design and technology decisions
- **DOMAIN_BOUNDARIES.md** - DDD implementation with Ash
- **PATTERNS_AND_PRACTICES.md** - Code patterns and best practices
- **REQUIREMENTS.md** - Functional and non-functional requirements
- **TEST_COVERAGE_AND_QUALITY.md** - Testing metrics and quality analysis

## 🧪 Development

### Running Tests

```bash
mix test                  # Run test suite
mix test --cover         # Generate coverage report
mix credo --strict       # Code quality checks
mix dialyzer            # Type checking
```

### Key Commands

```bash
mix phx.routes          # List all routes
mix ash.list           # Show Ash resources
mix boundary.validate  # Check module boundaries
```

## 📝 Learning Notes

This project explores several advanced Elixir/Phoenix concepts:

- **Ash Framework**: Declarative resource modeling with built-in validations
- **LiveView Streams**: Efficient real-time updates for large datasets
- **Boundary Enforcement**: Module dependency management
- **Keyset Pagination**: Scalable pagination for large result sets
- **CLDR Integration**: Internationalization and number formatting

## ⚠️ Limitations

As a learning project, this application has intentional limitations:

- No multi-tenancy support (all users share data)
- Limited to ~40% test coverage
- No production deployment configuration
- Missing advanced features (bank sync, OCR, etc.)
- No CI/CD pipeline setup

## 📄 License

This is a personal learning project. Feel free to explore the code and patterns, but please note it's not intended for production use.
