# HousekeepingBook - Requirements Documentation

## Executive Summary

HousekeepingBook is a multi-user financial tracking application designed for shared expense management between partners. It provides comprehensive financial record keeping with hierarchical categorization, flexible tagging, and timezone-aware reporting.

## Functional Requirements

### 1. User Management

#### 1.1 User Types

- **Normal Users**: Standard individual accounts with full access
- **Shared Users**: Accounts designed for shared access between partners

#### 1.2 Authentication Features

- User registration with email and password
- Password reset via email
- Email confirmation for new accounts
- Email change confirmation
- Session-based authentication with LiveView integration
- Token-based authentication for API access

#### 1.3 User Operations

- Create new user accounts
- Update user profile information
- Change email with confirmation
- Update password with current password verification
- Delete user accounts

### 2. Financial Record Management

#### 2.1 Record Attributes

- **Date**: Transaction date with timezone support
- **Amount**: Integer representation of monetary value
- **Description**: Optional text description
- **Payment Type**: Method of payment (card, cash, transfer, other)
- **Category**: Hierarchical categorization (required)
- **Subject**: User who made the transaction (required)
- **Tags**: Multiple labels for flexible organization

#### 2.2 CRUD Operations

- Create new financial records
- Read records with filtering and pagination
- Update existing records
- Delete records
- Bulk import from CSV files

#### 2.3 Record Queries

- List all records with pagination (keyset-based)
- Filter by date range (monthly views)
- Filter by category and type
- Search by tags
- Get nearest record by date
- Aggregate amounts by day and category type

### 3. Category Management

#### 3.1 Category Structure

- **Hierarchical Tree**: Parent-child relationships
- **Category Types**:
  - Expense (default)
  - Income
  - Saving
- **Validation**: Parent cannot be self

#### 3.2 Category Operations

- Create categories with optional parent
- Update category information
- Delete categories (with nilify on related records)
- Query top-level categories
- Query child categories by parent
- Query leaf categories (no children)

#### 3.3 Category Queries

- Get category by ID
- Get category by name and type
- List all categories
- Get bottom categories (leaves)

### 4. Tag Management

#### 4.1 Tag Features

- Simple name-based tags
- Many-to-many relationship with records
- Flexible labeling system

#### 4.2 Tag Operations

- Create new tags
- Update tag names
- Delete tags
- List all tags
- Get tag by ID

### 5. Reporting and Analytics

#### 5.1 Time-Based Reports

- **Monthly Reports**:
  - Records filtered by year-month
  - Total income/expense/balance
  - Daily aggregations
- **Daily Aggregations**:
  - Sum amounts by date and category type
  - Timezone-aware date grouping

#### 5.2 Category Analytics

- Expenses by category hierarchy
- Income sources breakdown
- Category performance tracking

### 6. Import/Export

#### 6.1 CSV Import

- Bulk record import from CSV files
- Custom field mapping
- Validation and error handling
- Category and tag creation during import

#### 6.2 Data Export (Planned)

- Export records to CSV
- Date range selection
- Category filtering

### 7. User Interface Features

#### 7.1 Real-time Updates

- LiveView-based reactive UI
- Instant updates without page refresh
- Stream-based efficient DOM updates

#### 7.2 Responsive Design

- Mobile-first approach
- Tailwind CSS styling
- Component-based architecture

#### 7.3 Internationalization

- Timezone support for all users
- Date/time formatting per locale
- Number formatting with CLDR
- Multi-language support (infrastructure ready)

## Non-Functional Requirements

### 1. Performance

- Keyset pagination for large datasets
- Efficient queries with indexed lookups
- Real-time updates via WebSockets
- Default limit of 1000 records per query

### 2. Security

- BCrypt password hashing
- Token-based authentication
- Environment-based secrets management
- SQL injection prevention via Ecto
- CSRF protection

### 3. Scalability

- Horizontal scaling ready with Phoenix
- Database connection pooling
- Stateless application design
- Asset fingerprinting for CDN

### 4. Maintainability

- Domain-driven design with clear boundaries
- Comprehensive test coverage
- Code quality tools (Credo, Dialyzer)
- Boundary enforcement for dependencies

### 5. Deployment

- Environment-based configuration
- Zero-downtime deployments
- SSL/TLS support
- Docker-ready architecture

## User Stories

### Epic: Personal Finance Management

1. **As a user**, I want to record my daily expenses so that I can track where my money goes
2. **As a user**, I want to categorize my expenses so that I can understand spending patterns
3. **As a user**, I want to view monthly reports so that I can budget effectively
4. **As a partner**, I want to share expense tracking with my significant other so we can manage joint finances
5. **As a user**, I want to import past transactions from CSV so that I don't have to enter them manually
6. **As a user**, I want to tag transactions flexibly so that I can organize them beyond categories
7. **As a user**, I want timezone-aware date handling so that transactions are recorded accurately when traveling

## Constraints

1. **Technical Constraints**
   - PostgreSQL database required
   - Elixir 1.14+ and Erlang/OTP 25+
   - Modern web browser with JavaScript enabled

2. **Business Constraints**
   - Multi-user support limited to authentication
   - No multi-tenancy (all users share data)
   - No built-in payment processing

3. **Regulatory Constraints**
   - GDPR compliance for user data
   - Secure password storage requirements
   - Data retention policies

## Future Enhancements

1. **Budgeting System** (Not Currently Implemented)
   - Monthly/yearly budget setting per category
   - Budget vs actual reporting
   - Alerts for budget overruns

2. **Advanced Analytics**
   - Trend analysis
   - Predictive spending patterns
   - Category recommendations

3. **Mobile Applications**
   - Native iOS app
   - Native Android app
   - Offline support with sync

4. **Integration Features**
   - Bank account synchronization
   - Receipt scanning with OCR
   - Export to accounting software

5. **Collaboration Features**
   - Shared budgets
   - Expense splitting
   - Approval workflows

