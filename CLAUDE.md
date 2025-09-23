# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HousekeepingBook is a personal expense tracking application built with Phoenix LiveView and Ash Framework. It's designed for sharing financial records between partners with multi-user support.

## Tech Stack

- **Framework**: Phoenix 1.7.10 with LiveView 0.20.1
- **Data Layer**: Ash Framework 3.0 with AshPostgres
- **Database**: PostgreSQL
- **Authentication**: Ash Authentication
- **CSS**: Tailwind CSS 3.3.2
- **JS Build**: ESBuild 0.17.11
- **Server**: Bandit adapter
- **Component Library**: Phoenix Storybook 0.6.0

## Common Commands

```bash
# Setup project (install deps, create DB, run migrations, build assets)
mix setup

# Start Phoenix server
mix phx.server
iex -S mix phx.server  # With interactive shell

# Database operations
mix ecto.create        # Create database
mix ecto.migrate       # Run migrations
mix ecto.reset         # Drop and recreate database
mix run priv/repo/seeds.exs  # Run seeds

# Testing
mix test               # Run all tests
mix test path/to/test_file.exs  # Run specific test file
mix test path/to/test_file.exs:LINE_NUMBER  # Run specific test

# Code quality
mix format             # Format code
mix credo             # Run static code analysis
mix dialyzer          # Run type checking

# Assets
mix assets.setup      # Install assets dependencies
mix assets.build      # Build assets
mix assets.deploy     # Build minified assets for production

# Phoenix Storybook (development only)
# Access at http://localhost:4000/storybook
```

## Architecture Overview

The application follows Phoenix's context-based architecture with Ash Framework for the data layer:

### Core Domains

1. **HousekeepingBook.Households** - Main business domain containing:
   - `Record` - Financial transactions with amount, date, category, tags
   - `Category` - Hierarchical categories (expense/income/saving types)
   - `Tag` - Labels for records to aid searching
   - `Subject` - User who made the transaction

2. **HousekeepingBook.Accounts** - User management and authentication:
   - `User` - User accounts with Ash Authentication
   - `UserToken` - Authentication tokens
   - Integrated with Ash Authentication Phoenix

### Key Architectural Patterns

- **Ash Resources**: All domain models use Ash.Resource with defined actions and code interfaces
- **LiveView**: All UI is implemented using Phoenix LiveView for real-time interactivity
- **Component-Based UI**: Reusable components in `core_components.ex` and `custom_components.ex`
- **Boundary**: Enforced module dependencies using the Boundary library

### Database Structure

- Records track financial transactions with categories and tags
- Categories support hierarchical tree structure with parent-child relationships
- Many-to-many relationship between Records and Tags via RecordTag
- User-based multi-tenancy for shared access between partners

### Authentication Flow

- Uses Ash Authentication with Phoenix integration
- Session-based authentication with LiveView
- Protected routes require authentication via `LiveUserAuth` mount hooks
- Admin routes under `/admin` namespace

### Frontend Structure

- Tailwind CSS for styling with custom configuration
- ESBuild for JavaScript bundling
- Phoenix LiveView for interactive components
- Storybook for component development and testing

## Key Files and Locations

- `lib/housekeeping_book/` - Core business logic
- `lib/housekeeping_book_web/` - Web interface
- `lib/housekeeping_book_web/live/` - LiveView modules
- `lib/housekeeping_book_web/components/` - Reusable UI components
- `priv/repo/migrations/` - Database migrations
- `assets/` - Frontend assets (JS, CSS)
- `storybook/` - Component stories for development

## Testing Approach

- ExUnit for testing with LiveView test helpers
- Test database configured with sandbox adapter
- BCrypt rounds reduced in test environment for performance
- Async tests supported with database sandbox

## Important Patterns

1. **Ash Actions**: Define data operations declaratively in resource modules
2. **LiveView Lifecycle**: Use mount hooks for authentication checks
3. **Component Functions**: Prefer function components over stateful components
4. **Date/Time Handling**: Timezone-aware operations with CLDR support
5. **Hierarchical Data**: Category tree structure with parent-child relationships

