# DBML Usage Guide
## How to Visualize Your Database Schema

---

## 📄 What is DBML?

**DBML** (Database Markup Language) is a simple, readable DSL language designed to define database structures. It's perfect for:
- 📊 Visualizing database schemas
- 📝 Documenting database designs
- 🔄 Sharing database structures
- 🎨 Creating ERD diagrams automatically

---

## 🚀 Quick Start - Visualize Your Schema

### Method 1: Using dbdiagram.io (Recommended)

**Step 1:** Open your browser and go to:
```
https://dbdiagram.io/d
```

**Step 2:** Copy the contents of `DATABASE_SCHEMA.dbml`

**Step 3:** Paste into the dbdiagram.io editor (left panel)

**Step 4:** Your complete ERD will appear automatically! 🎉

**Features You'll See:**
- ✅ All 12 tables with fields
- ✅ Data types and constraints
- ✅ Primary keys highlighted
- ✅ Indexes shown
- ✅ Table relationships (logical)
- ✅ Table groups (color-coded)
- ✅ Notes and descriptions

**Step 5:** Export your diagram:
- PDF (for printing)
- PNG (for presentations)
- SVG (for high-quality)
- SQL (to generate CREATE statements)

---

### Method 2: Using dbdocs.io (Documentation)

**Step 1:** Go to:
```
https://dbdocs.io/
```

**Step 2:** Sign in (free account)

**Step 3:** Upload `DATABASE_SCHEMA.dbml`

**Step 4:** Get a beautiful, interactive database documentation website!

**Features:**
- Searchable documentation
- Interactive schema explorer
- Shareable URL
- Version control
- Team collaboration

---

## 📊 What's Included in the DBML File

### All 12 Tables Defined

**Core Tables (4):**
1. ✅ `users` - User profile (local only)
2. ✅ `categories` - Income/expense categories
3. ✅ `transactions` - All income/expense records
4. ✅ `settings` - App preferences (key-value store)

**Financial Management (3):**
5. ✅ `balances` - Current, emergency, investment balances
6. ✅ `budgets` - Weekly, monthly, yearly budget limits
7. ✅ `financial_goals` - Savings goals and targets

**Asset Tracking (2):**
8. ✅ `assets` - User assets (property, vehicles, etc.)
9. ✅ `liabilities` - Debts and loans

**Advanced Features (3):**
10. ✅ `recurring_transactions` - Scheduled bills
11. ✅ `investments` - Investment portfolio
12. ✅ `emergency_funds` - Emergency fund allocations

---

### Complete Documentation

**For Each Table:**
- ✅ All columns with data types
- ✅ Primary keys marked
- ✅ Constraints (NOT NULL, UNIQUE, DEFAULT)
- ✅ Indexes defined
- ✅ Field descriptions
- ✅ Table notes and purpose

**Additional Information:**
- ✅ Enums for valid values
- ✅ Table groups (organized)
- ✅ Business logic notes
- ✅ Calculation formulas
- ✅ Performance notes
- ✅ Privacy considerations

---

## 🎨 Customizing the Visualization

### In dbdiagram.io:

**Change Colors:**
```dbml
Table users [headercolor: #3498db] {
  // Blue header for users table
}
```

**Add Relationships:**
```dbml
// Already included as logical references
// Uncomment to show relationship lines
Ref: transactions.category > categories.name
```

**Group Tables:**
```dbml
// Tables are already grouped:
// - core_tables (blue)
// - financial_management (green)
// - asset_tracking (orange)
// - advanced_features (purple)
```

**Export Options:**
- 📄 PDF - For reports
- 🖼️ PNG - For presentations
- 📐 SVG - For editing
- 💾 SQL - Generate CREATE statements

---

## 📋 Using the Generated Diagrams

### For Academic Reports

1. Export as **PDF** or **PNG**
2. Insert into PROJECT_REPORT.md (converted to PDF)
3. Caption: "Figure 5.1: Entity Relationship Diagram"
4. Reference in text: "As shown in Figure 5.1..."

### For Presentations

1. Export as **PNG** (high resolution)
2. Insert into PowerPoint/Google Slides
3. Use for:
   - Database design explanation
   - System architecture overview
   - Technical walkthrough

### For Documentation

1. Generate on **dbdocs.io**
2. Get shareable link
3. Include in README.md
4. Share with team/reviewers

---

## 🔍 Understanding the DBML Syntax

### Basic Table Definition

```dbml
Table table_name {
  column_name data_type [constraints, note: 'description']
}
```

### Column Attributes

```dbml
id integer [pk, increment]              // Primary key, auto-increment
name text [not null, unique]            // Required, unique value
amount real [default: 0]                // Default value
status text [null, note: 'Optional']   // Nullable with note
```

### Constraints

- `pk` - Primary key
- `increment` - Auto-increment
- `not null` - Required field
- `null` - Optional field
- `unique` - Unique values only
- `default: value` - Default value

### Indexes

```dbml
Table transactions {
  // columns...
  
  indexes {
    date [name: 'idx_date']              // Single column index
    (date, type) [name: 'idx_date_type'] // Composite index
  }
}
```

### Relationships

```dbml
// One-to-Many
Ref: table1.id < table2.foreign_id

// Many-to-One  
Ref: table1.foreign_id > table2.id

// One-to-One
Ref: table1.id - table2.id
```

---

## 📐 Sample Diagrams You Can Create

### 1. Full Schema Diagram
- All 12 tables
- All relationships
- Complete field list
- Use for: Technical documentation

### 2. Core Schema Only
- Just users, categories, transactions, settings
- Simplified view
- Use for: High-level overview

### 3. Financial Management Focus
- Budgets, goals, balances
- Use for: Budget feature explanation

### 4. Asset Tracking View
- Assets, liabilities
- Net worth calculation
- Use for: Asset management documentation

---

## 🛠️ Editing the DBML

### Add a New Table

```dbml
Table new_table {
  id integer [pk, increment]
  name text [not null]
  created_at text [not null, default: `datetime('now')`]
  
  Note: 'Description of what this table does'
}
```

### Add a New Column

```dbml
Table existing_table {
  // existing columns...
  new_column text [null, note: 'New field description']
}
```

### Add Relationships

```dbml
// Logical reference (not enforced FK)
Ref: transactions.category - categories.name [note: 'Reference by name']
```

---

## 📊 Advanced Features

### Table Groups (Color Coding)

Already included in the DBML:
- **core_tables** - Blue (Users, Categories, Transactions, Settings)
- **financial_management** - Green (Balances, Budgets, Goals)
- **asset_tracking** - Orange (Assets, Liabilities)
- **advanced_features** - Purple (Recurring, Investments, Emergency)

### Enums (Valid Values)

Defined for:
- transaction_type (income, expense)
- category_type (income, expense)
- budget_type (weekly, monthly, yearly)
- balance_type (current, emergency, investment)
- goal_status (active, completed, cancelled)
- investment_type (Stocks, Bonds, ETF, etc.)
- And more...

---

## 💡 Pro Tips

### For Best Visualization:

1. **Use Table Groups**: Already set up for you
2. **Add Notes**: Hover over tables to see descriptions
3. **Export High-Res**: Use SVG for best quality
4. **Save Your Work**: Create dbdiagram.io account
5. **Version Control**: Keep DBML in Git

### For Academic Reports:

1. Export diagram as **PNG (300 DPI)**
2. Add to report as **Figure 5.1**
3. Include data dictionary separately
4. Reference DBML file in appendix

### For Team Collaboration:

1. Upload to **dbdocs.io**
2. Get shareable documentation URL
3. Team can comment and review
4. Track schema changes over time

---

## 🎯 Common Use Cases

### Use Case 1: Explain Database to Professor

```
1. Open dbdiagram.io
2. Paste DATABASE_SCHEMA.dbml
3. Export as PNG
4. Add to presentation slide
5. Walk through each table group
```

### Use Case 2: Code Review

```
1. Upload DBML to dbdocs.io
2. Share link with reviewer
3. They can explore interactively
4. Add comments/suggestions
```

### Use Case 3: Generate SQL

```
1. Open DBML in dbdiagram.io
2. Click "Export" → "PostgreSQL/MySQL/SQLite"
3. Get CREATE TABLE statements
4. Compare with actual implementation
```

---

## 📱 Mobile-Friendly Viewing

Both dbdiagram.io and dbdocs.io work on mobile:
- 📱 View schema on phone
- 🖥️ Edit on desktop
- 🔄 Sync automatically

---

## 🔗 Useful Resources

**Official DBML Documentation:**
- https://dbml.dbdiagram.io/docs/

**dbdiagram.io:**
- https://dbdiagram.io/

**dbdocs.io:**
- https://dbdocs.io/

**DBML CLI Tool:**
```bash
npm install -g @dbml/cli
dbml2sql DATABASE_SCHEMA.dbml --sqlite
```

---

## ✅ Validation Checklist

Before using the DBML:

- [x] All 12 tables included
- [x] All columns defined
- [x] Data types specified
- [x] Constraints documented
- [x] Indexes defined
- [x] Notes added
- [x] Enums defined
- [x] Table groups organized
- [x] Privacy notes included
- [x] Business logic documented

---

## 🎓 Academic Presentation Tips

**For Your Report:**

1. **Include the ERD**: Export from dbdiagram.io as high-res PNG
2. **Reference the DBML**: Include DATABASE_SCHEMA.dbml in appendix
3. **Explain Design Choices**: Why denormalized? (Performance, offline-first)
4. **Show Evolution**: V1 → V2 → V3 → V4 migration path

**For Presentation:**

1. **Live Demo**: Open dbdiagram.io and show interactive schema
2. **Zoom into Details**: Click tables to expand
3. **Explain Relationships**: Show how data flows
4. **Highlight Privacy**: Point out offline-only design

---

## 📞 Support

**If you need help:**

- DBML syntax questions → https://dbml.dbdiagram.io/docs/
- Visualization issues → dbdiagram.io support
- Schema questions → Reference DATABASE_DESIGN_ACTUAL.md

---

## Document Information

**File:** DATABASE_SCHEMA.dbml  
**Format:** DBML (Database Markup Language)  
**Tables:** 12 tables fully defined  
**Compatible With:** dbdiagram.io, dbdocs.io, DBML CLI  
**Version:** 4.0  
**Last Updated:** October 10, 2025  

---

## Quick Links

📊 **Visualize Now:** Copy DBML → https://dbdiagram.io/d  
📚 **Create Docs:** Upload DBML → https://dbdocs.io/  
💻 **Learn DBML:** https://dbml.dbdiagram.io/docs/  

---

**Ready to visualize your database schema! 🎨**

