# FinEd Database Design Documentation
## Actual Implementation - SQLite Database Schema

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Database Tables Summary](#database-tables-summary)
3. [Complete Schema (As Implemented)](#complete-schema-as-implemented)
4. [Data Dictionary](#data-dictionary)
5. [Sample Data & Queries](#sample-data--queries)

---

## Overview

The FinEd database uses a **simplified, denormalized SQLite schema** optimized for **offline-only operation** and single-user scenarios. The design prioritizes simplicity and performance over strict normalization, which is appropriate for a mobile app with local-only storage.

**Database Engine:** SQLite 3.x  
**Database Name:** `expense_tracker.db`  
**Storage Location:** Local device storage (app-sandboxed directory)  
**Total Tables:** 12 tables  
**Database Version:** 4  
**Architecture:** Privacy-first, offline-only, single-user  
**Design Philosophy:** Denormalized for performance, no foreign key constraints

---

## Database Tables Summary

| # | Table Name | Purpose | Key Fields |
|---|------------|---------|------------|
| 1 | **transactions** | Core income/expense records | id, category, amount, type, date |
| 2 | **categories** | Income/expense categories | id, name, icon, color, type |
| 3 | **settings** | App configuration | key, value |
| 4 | **balances** | Current/emergency/investment balances | id, type, amount |
| 5 | **assets** | User assets (property, vehicles, etc.) | id, name, amount, category |
| 6 | **liabilities** | Debts and loans | id, name, amount, category |
| 7 | **budgets** | Budget limits | id, type, amount, spent |
| 8 | **users** | User profile (local only) | id, name, email |
| 9 | **financial_goals** | Savings goals | id, title, target_amount, current_amount |
| 10 | **recurring_transactions** | Scheduled recurring bills | id, title, amount, frequency |
| 11 | **investments** | Investment portfolio | id, name, type, quantity, purchase_price |
| 12 | **emergency_funds** | Emergency fund allocations | id, name, target_amount, current_amount |

---

## Complete Schema (As Implemented)

### 1. TRANSACTIONS Table

Stores all income and expense transactions.

```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,                    -- Category name (e.g., "🍕 Food & Dining")
  amount REAL NOT NULL,                      -- Negative for expenses, positive for income
  date TEXT NOT NULL,                        -- ISO 8601 date (YYYY-MM-DD)
  time TEXT NOT NULL,                        -- Time (HH:MM)
  asset TEXT NOT NULL,                       -- Payment method (Cash, Card, etc.)
  ledger TEXT NOT NULL,                      -- Account ledger (Personal, Work, etc.)
  remark TEXT,                               -- Optional note
  type TEXT NOT NULL,                        -- 'income' or 'expense'
  created_at TEXT NOT NULL,                  -- Creation timestamp
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

**Notes:**
- Category stored as TEXT (denormalized for simplicity)
- No foreign key to categories table
- Negative amounts for expenses, positive for income

---

### 2. CATEGORIES Table

Predefined and custom categories for transactions.

```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,                 -- Category name with emoji
  icon TEXT,                                 -- Emoji icon
  color TEXT,                                -- Hex color code
  type TEXT NOT NULL,                        -- 'income' or 'expense'
  is_default INTEGER NOT NULL DEFAULT 0,     -- 1 = system default, 0 = custom
  created_at TEXT NOT NULL                   -- Creation timestamp
);

-- Default categories inserted on database creation
INSERT INTO categories (name, icon, color, type, is_default, created_at) VALUES
  ('🍕 Food & Dining', '🍕', '#FF6B6B', 'expense', 1, datetime('now')),
  ('🚗 Transportation', '🚗', '#4ECDC4', 'expense', 1, datetime('now')),
  ('🛍️ Shopping', '🛍️', '#45B7D1', 'expense', 1, datetime('now')),
  ('🏠 Housing', '🏠', '#96CEB4', 'expense', 1, datetime('now')),
  ('💼 Salary', '💼', '#FFEAA7', 'income', 1, datetime('now')),
  ('🎁 Allowance', '🎁', '#DDA0DD', 'income', 1, datetime('now'));
```

---

### 3. SETTINGS Table

Key-value store for app preferences.

```sql
CREATE TABLE settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT NOT NULL UNIQUE,                  -- Setting key (e.g., 'theme', 'language')
  value TEXT NOT NULL,                       -- JSON-encoded value
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

**Common Settings:**
- `theme` → "light", "dark", or "system"
- `language` → "English", "Thai", etc.
- `currency` → "THB", "USD", "EUR"
- `monthly_start_date` → 1-31
- `tutorial_completed` → true/false

---

### 4. BALANCES Table

Stores different balance types (current, emergency, investment).

```sql
CREATE TABLE balances (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL UNIQUE,                 -- 'current', 'emergency', or 'investment'
  amount REAL NOT NULL DEFAULT 0.0,          -- Balance amount
  updated_at TEXT NOT NULL                   -- Last calculation timestamp
);

-- Default balances initialized on database creation
INSERT INTO balances (type, amount, updated_at) VALUES
  ('current', 0.0, datetime('now')),
  ('emergency', 0.0, datetime('now')),
  ('investment', 0.0, datetime('now'));
```

**Balance Types:**
- **current**: Day-to-day balance (calculated from transactions)
- **emergency**: Emergency fund total
- **investment**: Total investment portfolio value

---

### 5. ASSETS Table

User assets (property, vehicles, savings).

```sql
CREATE TABLE assets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                        -- Asset name (e.g., "House", "Car")
  amount REAL NOT NULL,                      -- Current value
  category TEXT NOT NULL,                    -- Asset category
  color TEXT NOT NULL,                       -- Display color (hex)
  created_at TEXT NOT NULL,                  -- Creation timestamp
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

---

### 6. LIABILITIES Table

Debts, loans, and financial obligations.

```sql
CREATE TABLE liabilities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                        -- Liability name (e.g., "Mortgage")
  amount REAL NOT NULL,                      -- Amount owed
  category TEXT NOT NULL,                    -- Liability category
  color TEXT NOT NULL,                       -- Display color (hex)
  created_at TEXT NOT NULL,                  -- Creation timestamp
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

---

### 7. BUDGETS Table

Weekly, monthly, and yearly budget limits.

```sql
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,                        -- 'weekly', 'monthly', or 'yearly'
  amount REAL NOT NULL,                      -- Budget limit
  spent REAL DEFAULT 0,                      -- Amount spent (auto-calculated)
  category TEXT,                             -- Optional category-specific budget
  created_at TEXT NOT NULL,                  -- Creation timestamp
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

---

### 8. USERS Table

Local user profile (no authentication).

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,                -- User email (local only)
  name TEXT NOT NULL,                        -- User name
  profile_image TEXT,                        -- Profile image path/URL
  created_at TEXT NOT NULL,                  -- Account creation timestamp
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

**Note:** In offline mode, typically only one user record exists.

---

### 9. FINANCIAL_GOALS Table

Savings goals and financial targets.

```sql
CREATE TABLE financial_goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,                       -- Goal name
  target_amount REAL NOT NULL,               -- Target savings
  current_amount REAL DEFAULT 0,             -- Current progress
  target_date TEXT,                          -- Target completion date
  category TEXT,                             -- Goal category
  priority INTEGER DEFAULT 1,                -- Priority (1-5)
  status TEXT DEFAULT 'active',              -- 'active', 'completed', 'cancelled'
  created_at TEXT NOT NULL,                  -- Creation timestamp
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

---

### 10. RECURRING_TRANSACTIONS Table

Scheduled recurring income/expenses.

```sql
CREATE TABLE recurring_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,                       -- Transaction title
  amount REAL NOT NULL,                      -- Transaction amount
  category TEXT NOT NULL,                    -- Category name
  frequency TEXT NOT NULL,                   -- 'daily', 'weekly', 'monthly', 'yearly'
  next_due_date TEXT NOT NULL,               -- Next occurrence date
  is_active INTEGER DEFAULT 1,               -- 1 = active, 0 = paused
  created_at TEXT NOT NULL,                  -- Creation timestamp
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

---

### 11. INVESTMENTS Table

Investment portfolio tracking.

```sql
CREATE TABLE investments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                        -- Investment name
  type TEXT NOT NULL,                        -- 'Stocks', 'Bonds', 'ETF', 'Crypto', etc.
  symbol TEXT,                               -- Stock symbol (optional)
  quantity REAL NOT NULL,                    -- Number of shares/units
  purchase_price REAL NOT NULL,              -- Purchase price per unit
  current_price REAL,                        -- Current market price (optional)
  purchase_date TEXT NOT NULL,               -- Purchase date
  created_at TEXT NOT NULL,                  -- Creation timestamp
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

**Value Calculation:**
```
Total Value = quantity × (current_price OR purchase_price)
```

---

### 12. EMERGENCY_FUNDS Table

Emergency fund allocations by category/purpose.

```sql
CREATE TABLE emergency_funds (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                        -- Fund name (e.g., "Medical Emergency")
  target_amount REAL NOT NULL,               -- Target fund amount
  current_amount REAL DEFAULT 0,             -- Current saved amount
  priority INTEGER DEFAULT 1,                -- Priority level
  created_at TEXT NOT NULL,                  -- Creation timestamp
  updated_at TEXT NOT NULL                   -- Last update timestamp
);
```

---

## Data Dictionary

### 📊 Complete Field Reference

#### TRANSACTIONS Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique transaction ID | 1 |
| **category** | TEXT | NOT NULL | Category name directly stored | "🍕 Food & Dining" |
| **amount** | REAL | NOT NULL | Negative for expense, positive for income | -450.50 |
| **date** | TEXT | NOT NULL | ISO 8601 date format | "2025-10-09" |
| **time** | TEXT | NOT NULL | HH:MM format | "14:30" |
| **asset** | TEXT | NOT NULL | Payment method | "Cash" |
| **ledger** | TEXT | NOT NULL | Account type | "Personal" |
| **remark** | TEXT | NULLABLE | Optional note | "Lunch at restaurant" |
| **type** | TEXT | NOT NULL | 'income' or 'expense' | "expense" |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-10-09T14:35:00Z" |
| **updated_at** | TEXT | NOT NULL | Last update timestamp | "2025-10-09T14:35:00Z" |

---

#### CATEGORIES Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique category ID | 1 |
| **name** | TEXT | NOT NULL, UNIQUE | Category name with emoji | "🍕 Food & Dining" |
| **icon** | TEXT | NULLABLE | Emoji representation | "🍕" |
| **color** | TEXT | NULLABLE | Hex color code | "#FF6B6B" |
| **type** | TEXT | NOT NULL | 'income' or 'expense' | "expense" |
| **is_default** | INTEGER | NOT NULL, DEFAULT 0 | 1=system, 0=custom | 1 |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-01-01T00:00:00Z" |

**Default Categories:**
- **Expenses**: 🍕 Food & Dining, 🚗 Transportation, 🛍️ Shopping, 🏠 Housing
- **Income**: 💼 Salary, 🎁 Allowance

---

#### SETTINGS Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Setting ID | 1 |
| **key** | TEXT | NOT NULL, UNIQUE | Setting key | "theme" |
| **value** | TEXT | NOT NULL | JSON-encoded value | "\"dark\"" |
| **updated_at** | TEXT | NOT NULL | Last update | "2025-10-10T12:00:00Z" |

**Common Settings Keys:**
- `theme` → "light", "dark", "system"
- `language` → "English", "Thai"
- `currency` → "Thai Baht (฿)", "US Dollar ($)"

---

#### BALANCES Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Balance ID | 1 |
| **type** | TEXT | NOT NULL, UNIQUE | Balance type | "current" |
| **amount** | REAL | NOT NULL, DEFAULT 0.0 | Balance amount | 12500.75 |
| **updated_at** | TEXT | NOT NULL | Last calculation time | "2025-10-10T16:45:00Z" |

**Balance Types:**
- `current` → Main spending balance
- `emergency` → Emergency fund
- `investment` → Investment portfolio value

---

#### ASSETS Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Asset ID | 1 |
| **name** | TEXT | NOT NULL | Asset name | "🏠 House" |
| **amount** | REAL | NOT NULL | Current value | 2500000.00 |
| **category** | TEXT | NOT NULL | Asset category | "Real Estate" |
| **color** | TEXT | NOT NULL | Display color | "#4CAF50" |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-01-10T09:00:00Z" |
| **updated_at** | TEXT | NOT NULL | Last update | "2025-10-10T11:00:00Z" |

---

#### LIABILITIES Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Liability ID | 1 |
| **name** | TEXT | NOT NULL | Liability name | "🏠 Mortgage" |
| **amount** | REAL | NOT NULL | Amount owed | 1800000.00 |
| **category** | TEXT | NOT NULL | Liability category | "Real Estate" |
| **color** | TEXT | NOT NULL | Display color | "#F44336" |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-01-05T08:00:00Z" |
| **updated_at** | TEXT | NOT NULL | Last update | "2025-10-10T13:00:00Z" |

---

#### BUDGETS Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Budget ID | 1 |
| **type** | TEXT | NOT NULL | 'weekly', 'monthly', 'yearly' | "monthly" |
| **amount** | REAL | NOT NULL | Budget limit | 10000.00 |
| **spent** | REAL | DEFAULT 0 | Amount spent | 6500.50 |
| **category** | TEXT | NULLABLE | Optional category filter | "🍕 Food & Dining" |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-01-01T00:00:00Z" |
| **updated_at** | TEXT | NOT NULL | Last update | "2025-10-10T12:00:00Z" |

**Budget Status:**
- **Good**: spent < 80% of amount
- **Warning**: spent >= 80% and < 100%
- **Over Budget**: spent >= 100%

---

#### USERS Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | User ID | 1 |
| **email** | TEXT | UNIQUE, NOT NULL | Email (local only) | "user@example.com" |
| **name** | TEXT | NOT NULL | User name | "John Doe" |
| **profile_image** | TEXT | NULLABLE | Profile image path | "/images/profile.jpg" |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-01-15T10:00:00Z" |
| **updated_at** | TEXT | NOT NULL | Last update | "2025-10-10T15:30:00Z" |

**Note:** Single-user app typically has only one user record.

---

#### FINANCIAL_GOALS Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Goal ID | 1 |
| **title** | TEXT | NOT NULL | Goal name | "Buy Laptop" |
| **target_amount** | REAL | NOT NULL | Target amount | 30000.00 |
| **current_amount** | REAL | DEFAULT 0 | Current savings | 15000.00 |
| **target_date** | TEXT | NULLABLE | Target date | "2025-12-31" |
| **category** | TEXT | NULLABLE | Goal category | "Education" |
| **priority** | INTEGER | DEFAULT 1 | Priority (1-5) | 2 |
| **status** | TEXT | DEFAULT 'active' | Goal status | "active" |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-01-15T10:00:00Z" |
| **updated_at** | TEXT | NOT NULL | Last update | "2025-10-10T15:30:00Z" |

**Status Values:**
- `active` → Currently pursuing
- `completed` → Goal achieved
- `cancelled` → Goal abandoned

---

#### RECURRING_TRANSACTIONS Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Recurring transaction ID | 1 |
| **title** | TEXT | NOT NULL | Transaction title | "Monthly Rent" |
| **amount** | REAL | NOT NULL | Transaction amount | -8000.00 |
| **category** | TEXT | NOT NULL | Category name | "🏠 Housing" |
| **frequency** | TEXT | NOT NULL | Recurrence frequency | "monthly" |
| **next_due_date** | TEXT | NOT NULL | Next occurrence date | "2025-11-01" |
| **is_active** | INTEGER | DEFAULT 1 | 1=active, 0=paused | 1 |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-01-01T00:00:00Z" |
| **updated_at** | TEXT | NOT NULL | Last update | "2025-10-10T12:00:00Z" |

**Frequency Options:**
- `daily` → Every day
- `weekly` → Every 7 days
- `biweekly` → Every 14 days
- `monthly` → Every month on same date
- `quarterly` → Every 3 months
- `yearly` → Every year

---

#### INVESTMENTS Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Investment ID | 1 |
| **name** | TEXT | NOT NULL | Investment name | "Apple Inc." |
| **type** | TEXT | NOT NULL | Investment type | "Stocks" |
| **symbol** | TEXT | NULLABLE | Stock symbol | "AAPL" |
| **quantity** | REAL | NOT NULL | Number of shares/units | 10.0 |
| **purchase_price** | REAL | NOT NULL | Purchase price per unit | 150.00 |
| **current_price** | REAL | NULLABLE | Current market price | 180.00 |
| **purchase_date** | TEXT | NOT NULL | Purchase date | "2025-01-15" |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-01-15T10:00:00Z" |
| **updated_at** | TEXT | NOT NULL | Last update | "2025-10-10T14:00:00Z" |

**Investment Types:**
- Stocks, Bonds, Mutual Fund, ETF, Cryptocurrency, Real Estate

**Value Calculation:**
```
Total Value = quantity × (current_price OR purchase_price if current_price is NULL)
```

---

#### EMERGENCY_FUNDS Table

| Column | Type | Constraints | Description | Example |
|--------|------|-------------|-------------|---------|
| **id** | INTEGER | PRIMARY KEY, AUTOINCREMENT | Emergency fund ID | 1 |
| **name** | TEXT | NOT NULL | Fund name | "Medical Emergency" |
| **target_amount** | REAL | NOT NULL | Target fund size | 50000.00 |
| **current_amount** | REAL | DEFAULT 0 | Current saved amount | 25000.00 |
| **priority** | INTEGER | DEFAULT 1 | Priority level | 1 |
| **created_at** | TEXT | NOT NULL | Creation timestamp | "2025-01-20T09:00:00Z" |
| **updated_at** | TEXT | NOT NULL | Last update | "2025-10-10T16:00:00Z" |

---

## Sample Data & Queries

### Sample Data Insert

```sql
-- Insert a user
INSERT INTO users (email, name, profile_image, created_at, updated_at) VALUES
  ('student@example.com', 'Student', NULL, datetime('now'), datetime('now'));

-- Insert expense transaction
INSERT INTO transactions (category, amount, date, time, asset, ledger, remark, type, created_at, updated_at) VALUES
  ('🍕 Food & Dining', -450.00, '2025-10-09', '12:00', 'Cash', 'Personal', 'Lunch', 'expense', datetime('now'), datetime('now'));

-- Insert income transaction
INSERT INTO transactions (category, amount, date, time, asset, ledger, remark, type, created_at, updated_at) VALUES
  ('💼 Salary', 25000.00, '2025-10-01', '09:00', 'Bank Transfer', 'Personal', 'Monthly salary', 'income', datetime('now'), datetime('now'));
```

### Common Queries

**1. Get Total Current Balance**
```sql
SELECT SUM(amount) as current_balance
FROM transactions
WHERE type IN ('income', 'expense');
```

**2. Get Monthly Expenses by Category**
```sql
SELECT 
  category,
  SUM(ABS(amount)) as total
FROM transactions
WHERE type = 'expense'
  AND date >= date('now', 'start of month')
  AND date <= date('now')
GROUP BY category
ORDER BY total DESC;
```

**3. Calculate Budget Status**
```sql
SELECT 
  type,
  amount as budget_limit,
  spent as budget_spent,
  (spent / amount * 100) as percentage_used,
  (amount - spent) as remaining
FROM budgets
WHERE type = 'monthly';
```

**4. Get All Active Financial Goals with Progress**
```sql
SELECT 
  title,
  target_amount,
  current_amount,
  (current_amount / target_amount * 100) as progress_percentage,
  (target_amount - current_amount) as remaining,
  target_date
FROM financial_goals
WHERE status = 'active'
ORDER BY priority ASC, target_date ASC;
```

**5. Calculate Net Worth**
```sql
SELECT 
  (SELECT COALESCE(SUM(amount), 0) FROM assets) -
  (SELECT COALESCE(SUM(amount), 0) FROM liabilities) as net_worth;
```

**6. Get Investment Portfolio Value**
```sql
SELECT 
  name,
  type,
  quantity,
  purchase_price,
  COALESCE(current_price, purchase_price) as price,
  quantity * COALESCE(current_price, purchase_price) as total_value
FROM investments
ORDER BY total_value DESC;
```

---

## Key Design Decisions

### Why Denormalized Schema?

**Advantages for Offline Mobile App:**

1. **Simpler Queries**: No complex JOINs required for common operations
2. **Better Performance**: Fewer table lookups on mobile devices
3. **Easier to Understand**: More straightforward for single-developer projects
4. **Less Overhead**: No foreign key constraint checking overhead
5. **Flexible Schema**: Easier to modify categories without breaking transactions

**Trade-offs:**
- Data redundancy (category names repeated in transactions)
- Manual consistency management
- Larger database size for many transactions

**Why This Works Here:**
- Single-user app (no multi-user complexity)
- Limited categories (< 50 categories expected)
- Offline-only (no concurrent access issues)
- Performance-critical on mobile devices

---

## Database Maintenance

### Recalculate All Balances

This function runs after every transaction insert/update/delete:

```dart
Future<void> recalculateAllBalances() async {
  // 1. Calculate current balance from all transactions
  final totalBalance = SUM(transactions.amount);
  UPDATE balances SET amount = totalBalance WHERE type = 'current';
  
  // 2. Calculate emergency fund balance
  final emergencyTotal = SUM(emergency_funds.current_amount);
  UPDATE balances SET amount = emergencyTotal WHERE type = 'emergency';
  
  // 3. Calculate investment balance
  final investmentTotal = SUM(
    investments.quantity × COALESCE(current_price, purchase_price)
  );
  UPDATE balances SET amount = investmentTotal WHERE type = 'investment';
  
  // 4. Update budget spent amounts (weekly, monthly, yearly)
  UPDATE budgets SET spent = calculated_spent_for_period;
}
```

### Database Optimization

```sql
-- Create indexes for faster queries
CREATE INDEX idx_transactions_date ON transactions(date DESC);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_category ON transactions(category);

-- Maintenance tasks
VACUUM;                    -- Reclaim unused space
ANALYZE;                   -- Update query optimizer statistics
PRAGMA integrity_check;    -- Verify database integrity
```

---

## Schema Evolution

### Version History

| Version | Tables Added | Description |
|---------|--------------|-------------|
| **v1** | transactions, categories, settings, balances | Initial core tables |
| **v2** | assets, liabilities | Net worth tracking |
| **v3** | budgets | Budget management |
| **v4** | users, financial_goals, recurring_transactions, investments, emergency_funds | Complete feature set |

---

## Simplified ERD (Actual Implementation)

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  CATEGORIES  │     │ TRANSACTIONS │     │   BUDGETS    │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id (PK)      │     │ id (PK)      │     │ id (PK)      │
│ name         │     │ category ───────→ (name)        │
│ type         │     │ amount       │     │ type         │
│ icon         │     │ type         │     │ amount       │
│ color        │     │ date         │     │ spent        │
└──────────────┘     │ time         │     │ category     │
                     │ asset        │     └──────────────┘
┌──────────────┐     │ ledger       │     
│    USERS     │     │ remark       │     ┌──────────────┐
├──────────────┤     └──────────────┘     │  BALANCES    │
│ id (PK)      │                          ├──────────────┤
│ name         │                          │ id (PK)      │
│ email        │                          │ type         │
└──────────────┘                          │ amount       │
                                          └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   ASSETS     │     │ LIABILITIES  │     │    GOALS     │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id (PK)      │     │ id (PK)      │     │ id (PK)      │
│ name         │     │ name         │     │ title        │
│ amount       │     │ amount       │     │ target_amt   │
│ category     │     │ category     │     │ current_amt  │
└──────────────┘     └──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ INVESTMENTS  │     │ RECURRING_TX │     │ EMERGENCY_F  │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id (PK)      │     │ id (PK)      │     │ id (PK)      │
│ name         │     │ title        │     │ name         │
│ type         │     │ amount       │     │ target_amt   │
│ quantity     │     │ frequency    │     │ current_amt  │
│ purchase_$   │     │ next_due     │     │ priority     │
│ current_$    │     └──────────────┘     └──────────────┘
└──────────────┘
```

**Note:** No explicit foreign key relationships in the actual implementation. Categories referenced by name (TEXT) in transactions and budgets.

---

## Important Notes

### Actual vs Ideal Design

**What's Actually Implemented:**
- ✅ Simple, denormalized schema
- ✅ No foreign key constraints
- ✅ Categories stored as TEXT in transactions
- ✅ No user_id in most tables (single-user app)
- ✅ Optimized for offline performance

**What's in the Ideal/Normalized Version:**
- ❌ Foreign key constraints
- ❌ category_id references
- ❌ user_id in all tables
- ❌ Strict referential integrity

**Why the Difference?**

The actual implementation uses a **pragmatic, simplified approach** because:
1. Single-user app doesn't need user_id everywhere
2. Denormalized categories improve query performance
3. No concurrent multi-user access to worry about
4. Simpler codebase easier to maintain
5. Mobile devices benefit from fewer JOIN operations

---

## Privacy & Performance

### Storage Size

**Typical Database Size:**
- 100 transactions: ~50 KB
- 1,000 transactions: ~500 KB
- 10,000 transactions: ~5 MB
- Full year data: ~1-2 MB

**Performance:**
- Transaction insert: ~30ms
- Balance calculation: ~145ms
- Monthly report query: ~80ms
- All queries under 200ms ✅

### Privacy Features

- ✅ 100% offline operation
- ✅ All data stored locally in SQLite
- ✅ Database location: App-sandboxed directory
- ✅ No external network calls
- ✅ No user authentication required
- ✅ Complete user data control

---

## Document Information

**Document Title:** FinEd Database Design - Actual Implementation  
**Version:** 1.0  
**Last Updated:** October 10, 2025  
**Database Version:** 4  
**Total Tables:** 12  
**Design Pattern:** Denormalized for performance  

---

**END OF DOCUMENT**

