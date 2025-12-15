# Product Requirement Document (PRD)

## Project Name: NeuralCash
**Automated Privacy-First Financial Intelligence Platform**

---

**Version:** 2.0  
**Status:** In-Development  
**Last Updated:** December 2025  
**Tech Stack:** React.js (Frontend), Node.js (Backend), Supabase (Database & Auth)

---

## 1. Executive Summary

### 1.1. Product Vision
To create a privacy-centric, AI-driven financial management platform that empowers users to track, categorize, and optimize their spending without relying on intrusive third-party banking APIs. The system leverages local/edge-friendly AI to provide behavioral "nudges" (Cross-Cut logic), predictive analytics, trip planning assistance, and intelligent savings recommendations, bridging the gap between simple expense tracking and complex financial planning.

### 1.2. Key Objectives
- **Privacy First:** Zero dependency on Plaid/Yodlee. Data belongs to the user.
- **AI Autonomy:** 90%+ accuracy in categorizing raw transaction text (e.g., "UPI-STARBUCKS-MUM") into semantic categories (e.g., "Dining").
- **Behavioral Intelligence:** Go beyond tracking to suggest actionable trade-offs (e.g., "You bought a laptop; reduce fuel spend this month").
- **Predictive Analytics:** Forecast future expenses based on recurring patterns and special events.
- **Family Sync:** Allow household budget management with role-based access and person-wise expense analysis.
- **Tax & Savings Intelligence:** Include tax calculations, short-term and long-term savings targets with intelligent notifications.
- **Trip Planning:** Integrated travel budgeting with petrol, hotel, and commission-based suggestions.

### 1.3. Target Audience
- **Students/Young Professionals:** Managing limited budgets and gig-economy income.
- **Privacy Advocates:** Users who refuse to link bank credentials to apps.
- **Families:** Joint expense tracking without shared bank accounts.
- **Travelers:** Users planning trips with budget constraints and looking for personalized recommendations.

### 1.4. Unique Value Propositions
1. **Bill Upload → Auto-Categorize:** Upload receipt, AI extracts and categorizes.
2. **Next Month Prediction:** "Starbucks coffee → next month ↑" predicts spending patterns and special occasions.
3. **Person-wise Family Analysis:** Track who spends what in a family setup.
4. **Cross-Cut Logic:** "Laptop buy → Fuel cut" intelligent budget rebalancing.
5. **Trip Planning Module:** Budget estimator with petrol, hotel suggestions, and commission-based recommendations.
6. **Medical Expense Prediction:** Future prediction of recurring medical expenses.
7. **Savings Target Management:** Short-term (₹1000/month) and long-term goals with progress tracking.
8. **Loop Detection:** Identifies circular transfers (Me → Somebody → Me → Loop) to avoid double-counting.
9. **Installment Tracking:** "Profit: Installment process → 3 months, 1st month → 2 months → Extra fund → Loan to others."

---

## 2. System Architecture & Tech Stack

### 2.1. High-Level Architecture
The system follows a **Client-Server-Database** architecture designed to act like a "Thick Client" (PWA) to support offline entry.

```
┌─────────────────┐
│   React PWA     │ ← User Interface Layer
│   (Frontend)    │
└────────┬────────┘
         │ HTTPS/REST
         ↓
┌─────────────────┐
│   Node.js API   │ ← Business Logic + AI Engine
│   (Backend)     │
└────────┬────────┘
         │ SQL/Auth
         ↓
┌─────────────────┐
│   Supabase      │ ← PostgreSQL + Storage + Auth
│   (Database)    │
└─────────────────┘
```

### 2.2. Technology Specifications

#### Frontend
- **Framework:** React 18+ (Vite for build)
- **State Management:** Zustand or Redux Toolkit
- **Styling:** Tailwind CSS (responsive design)
- **Charts:** Recharts or Chart.js
- **PWA Support:** vite-plugin-pwa for offline capability
- **Camera/OCR:** HTML5 Media Capture API + Tesseract.js integration
- **Forms:** React Hook Form + Zod validation

#### Backend
- **Runtime:** Node.js (v18+)
- **Framework:** Express.js
- **NLP Library:** natural (Tokenizer, TF-IDF, Bayes Classifier)
- **Validation:** Joi or Zod
- **OCR:** Tesseract.js (server-side)
- **Caching:** Redis (optional, for performance)
- **Job Queue:** Bull (for async tasks like OCR processing)

#### Database (Supabase)
- **Auth:** Supabase Auth (Email/Password, Magic Link)
- **DB:** PostgreSQL with Row Level Security (RLS)
- **Storage:** Supabase Storage (for Bill/Receipt images)
- **Real-time:** Supabase Realtime (for family sync)

---

## 3. Database Schema (Supabase)

### 3.1. Entity Relationship Diagram (ERD) Overview

```
profiles (1) ↔ (M) transactions
profiles (1) ↔ (M) categories
families (1) ↔ (M) profiles
transactions (1) ↔ (1) receipts
profiles (1) ↔ (M) savings_goals
profiles (1) ↔ (M) trips
transactions (M) ↔ (1) trips
```

### 3.2. Table Definitions

#### Table: `profiles`
Extends Supabase Auth with user preferences.

```sql
create table profiles (
  id uuid references auth.users not null primary key,
  full_name text,
  currency_symbol text default '₹',
  monthly_income_target numeric,
  tax_percentage numeric default 30, -- Income tax rate
  savings_goal_short_term numeric, -- e.g., ₹1000/month
  savings_goal_long_term numeric, -- e.g., ₹5000/month
  family_id uuid references families(id),
  notification_preferences jsonb default '{"reduce_this": true, "cross_cut": true, "savings_alert": true}'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);
```

#### Table: `families`
Family/household grouping.

```sql
create table families (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  invite_code text unique not null, -- 6-digit code for joining
  created_by uuid references profiles(id),
  created_at timestamp with time zone default timezone('utc'::text, now())
);
```

#### Table: `categories`
User-customizable taxonomy with keywords and budgets.

```sql
create table categories (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id),
  family_id uuid references families(id), -- Shared categories for family
  name text not null, -- e.g., "Dining", "Fuel"
  type text not null check (type in ('income', 'expense')),
  keywords text[], -- Array of strings for rule-based overrides
  monthly_budget numeric default 0,
  is_flexible boolean default false, -- Can be reduced in cross-cut logic
  is_system_default boolean default false,
  icon text, -- Icon name/emoji
  created_at timestamp with time zone default timezone('utc'::text, now())
);
```

#### Table: `transactions`
The core financial ledger.

```sql
create table transactions (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) not null,
  family_id uuid references families(id), -- If part of family budget
  amount numeric not null,
  description_raw text not null, -- "UPI-AMAZON-PAY-123"
  merchant_clean text, -- "Amazon"
  category_id uuid references categories(id),
  transaction_date timestamp not null,
  
  -- AI Fields
  is_ai_categorized boolean default true,
  confidence_score float, -- 0.0 to 1.0
  
  -- Workflow Fields
  status text check (status in ('pending_approval', 'approved', 'rejected')) default 'approved',
  payment_method text check (payment_method in ('cash', 'online', 'credit_card', 'upi')),
  
  -- Privacy
  is_personal boolean default false, -- Hidden from family view
  
  -- Behavioral Fields
  is_loop_transfer boolean default false, -- Detected as internal transfer
  loop_pair_id uuid references transactions(id), -- Link to the other half
  is_recurring boolean default false, -- Predicted recurring expense
  recurrence_pattern text, -- 'monthly', 'quarterly', etc.
  next_predicted_date timestamp,
  
  -- Special Categories
  is_special_occasion boolean default false, -- Birthday, anniversary, etc.
  occasion_name text,
  
  -- Installment Tracking
  is_installment boolean default false,
  installment_plan_id uuid, -- Group installments together
  installment_number int, -- 1 of 3, 2 of 3, etc.
  total_installments int,
  
  -- Trip Association
  trip_id uuid references trips(id),
  
  -- Receipt
  receipt_url text, -- Supabase Storage URL
  receipt_extracted_data jsonb, -- OCR results
  
  -- Metadata
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Indexes for performance
create index idx_transactions_user on transactions(user_id);
create index idx_transactions_date on transactions(transaction_date);
create index idx_transactions_category on transactions(category_id);
```

#### Table: `budgets_and_goals`
Category-wise monthly budgets.

```sql
create table budgets_and_goals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id),
  category_id uuid references categories(id),
  target_amount numeric,
  alert_threshold numeric, -- e.g., 80% triggers notification
  month date, -- Store as '2025-12-01'
  is_exceeded boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now())
);
```

#### Table: `savings_goals`
Short-term and long-term savings tracking.

```sql
create table savings_goals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) not null,
  goal_name text not null, -- "Emergency Fund", "Vacation"
  goal_type text check (goal_type in ('short_term', 'long_term')),
  target_amount numeric not null,
  current_amount numeric default 0,
  monthly_contribution numeric, -- Expected monthly savings
  target_date date,
  status text check (status in ('in_progress', 'completed', 'paused')) default 'in_progress',
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);
```

#### Table: `trips`
Trip planning and expense tracking.

```sql
create table trips (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) not null,
  trip_name text not null,
  destination text,
  start_date date,
  end_date date,
  estimated_budget numeric,
  actual_spent numeric default 0,
  
  -- Trip Components
  estimated_petrol_cost numeric,
  estimated_hotel_cost numeric,
  suggested_hotels jsonb, -- Array of hotel suggestions with commission info
  
  -- Rapido/Uber estimates
  estimated_transport_cost numeric,
  transport_suggestions jsonb,
  
  status text check (status in ('planning', 'ongoing', 'completed')) default 'planning',
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);
```

#### Table: `installment_plans`
Track loan repayments and installment purchases.

```sql
create table installment_plans (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) not null,
  plan_name text not null, -- "Phone EMI", "Loan to Friend"
  total_amount numeric not null,
  remaining_amount numeric not null,
  monthly_amount numeric not null,
  start_date date,
  end_date date,
  plan_type text check (plan_type in ('loan_given', 'loan_taken', 'emi', 'investment')),
  is_extra_fund_available boolean default false, -- Can be loaned to others
  status text check (status in ('active', 'completed', 'defaulted')) default 'active',
  created_at timestamp with time zone default timezone('utc'::text, now())
);
```

#### Table: `notifications`
System-generated alerts and suggestions.

```sql
create table notifications (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) not null,
  notification_type text check (notification_type in ('reduce_this', 'cross_cut', 'savings_exceeded', 'budget_alert', 'recurring_prediction')),
  title text not null,
  message text not null,
  action_data jsonb, -- Contains suggestions, links, etc.
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now())
);
```

#### Table: `ai_feedback`
Store user corrections for AI learning.

```sql
create table ai_feedback (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) not null,
  transaction_description text not null,
  ai_predicted_category text,
  user_corrected_category text,
  confidence_score float,
  created_at timestamp with time zone default timezone('utc'::text, now())
);
```

---

## 4. Functional Requirements

### 4.1. Module: Authentication & Onboarding

**FR-01:** User shall sign up using Email/Password or Magic Link via Supabase Auth.

**FR-02:** Upon first login, the system shall:
- Create a profile entry
- Spawn a default set of categories (Food, Travel, Bills, Salary, Fuel, Entertainment, Medical)
- Display onboarding wizard to set monthly income, tax rate, and savings goals

**FR-03:** User can create a "Family Group" with a unique 6-digit invite code or join an existing family using the code.

**FR-04:** Family admin can set shared categories and view aggregated expenses.

### 4.2. Module: Transaction Ingestion

**FR-05:** **Manual Entry (Cash/Online/UPI):**
- User provides Amount, Date, Description, Payment Method
- System allows tagging as "Personal" (hidden from family)
- Real-time AI categorization as user types

**FR-06:** **Receipt Upload (OCR):**
- User uploads image via camera or gallery
- Frontend sends image to Backend
- Backend uses Tesseract.js to extract text
- Parsed fields: Date, Amount, Merchant, Items
- User confirms/edits before saving

**FR-07:** **Bulk Import (CSV):**
- User uploads bank statement CSV
- System parses rows with column mapping
- Batch AI categorization
- Review screen before final import

**FR-08:** **Voice Entry (Bonus Feature):**
- User speaks: "Fifty rupees at Starbucks yesterday"
- System uses Web Speech API → parses → creates transaction

### 4.3. Module: The AI Engine (Node.js)

**FR-09:** **Pre-processing Pipeline:**
```
Input: "UPI/234234/STARBUCKS COFFEE/MUMBAI"
↓
Remove: UPI, numbers, special chars, stop words ("pvt", "ltd")
↓
Output: "starbucks coffee mumbai"
```

**FR-10:** **Categorization (Hybrid Approach):**
1. **Rule-based:** Check `categories.keywords` array for exact matches
2. **TF-IDF Classifier:** If no rule match, use trained model
3. **User-specific Learning:** Personalized classifier per user based on corrections

**FR-11:** **Merchant Extraction:**
- Extract clean merchant name from raw transaction text
- Build merchant database for future quick categorization

**FR-12:** **Confidence Scoring:**
- Return confidence score (0.0 to 1.0)
- If < 0.6, flag for user review (orange indicator)

**FR-13:** **Feedback Loop:**
- When user manually changes category, store in `ai_feedback` table
- Retrain user-specific classifier weekly
- Global model improves with aggregated anonymous feedback

### 4.4. Module: Behavioral Analytics ("The Brain")

**FR-14:** **Cross-Cut Logic (Laptop vs. Fuel Feature):**
```
Trigger: Transaction > ₹10,000 in "Discretionary" category (Electronics, Luxury)
↓
Algorithm:
1. Calculate remaining disposable income for month
2. Identify "Flexible" categories (is_flexible = true)
3. Calculate suggested reduction percentage
↓
Generate Notification:
"High spending detected on Electronics (₹25,000). 
Suggest reducing Fuel budget by 15% (₹2,250) to stay on track."
```

**FR-15:** **Loop Detection (Transfer Identification):**
```
Logic:
1. Scan last 48 hours
2. Look for Outflow A → Person X (amount ≈ Y)
3. Look for Inflow Person X → A (amount ≈ Y ± 1%)
↓
Action:
- Mark both transactions as is_loop_transfer = true
- Link via loop_pair_id
- Exclude from "Total Expense" calculations
- Display in grey color with "Transfer" label
```

**FR-16:** **Recurring Expense Prediction:**
```
Algorithm:
1. Analyze last 12 months of data
2. Detect patterns (same merchant, similar amount, regular interval)
3. Flag as is_recurring = true
4. Calculate next_predicted_date
5. Reserve estimated amount in monthly budget
↓
Examples:
- "Medical checkup every 3 months"
- "LIC premium every quarter"
- "Netflix subscription monthly"
```

**FR-17:** **Special Occasion Prediction:**
```
Logic:
1. User marks transactions as "Birthday", "Anniversary" (first time)
2. System remembers date
3. Predicts next year → reserves budget
4. Sends reminder 1 week before
↓
Example:
"Mom's birthday coming up on Dec 15. Based on last year (₹3,500), 
we've reserved ₹4,000 in your December budget."
```

**FR-18:** **Future Medical Expense Prediction:**
```
Logic:
1. Identify "Medical" category transactions
2. Calculate average and frequency
3. Predict short-term (next 3 months)
↓
Display:
"Based on patterns, expect ₹2,000 medical expense in February 2026."
```

### 4.5. Module: Savings & Tax Management

**FR-19:** **Tax Calculation:**
- Apply tax_percentage from profile to monthly income
- Display "Post-tax Income" on dashboard
- Show monthly tax obligation

**FR-20:** **Savings Target Tracking:**
- **Short-term:** Goals < 6 months (e.g., ₹1000/month for new phone)
- **Long-term:** Goals > 6 months (e.g., ₹5000/month for vacation)
- Progress bars on dashboard
- Color-coded: Green (on track), Yellow (behind), Red (missed)

**FR-21:** **Savings Exceeded Notification:**
```
Trigger: Current month savings > target + 20%
↓
Notification:
"Great job! You've saved ₹6,000 this month (target: ₹5,000).
If savings exceed target, consider:
- Moving excess to long-term goal
- Starting a new short-term goal"
```

### 4.6. Module: Installment & Loan Tracking

**FR-22:** **Installment Plan Creation:**
- User creates plan: EMI, Loan given, Loan taken
- System tracks monthly payments
- Links transactions to installment_plan_id

**FR-23:** **Extra Fund Management:**
```
Scenario: User completes installment early
↓
System marks: is_extra_fund_available = true
↓
Suggestion: "You have ₹10,000 extra fund from completed EMI. 
Can be loaned to others or moved to savings."
```

**FR-24:** **Profit from Installments:**
```
Example: 3-month loan given
Month 1: ₹5,000 received
Month 2: ₹5,000 received  
Month 3: Extra ₹1,000 interest
↓
System tracks profit separately from principal
```

### 4.7. Module: Trip Planning

**FR-25:** **Trip Creation & Budget Estimation:**
- User inputs: Destination, Dates, Estimated Budget
- System calculates:
  - **Petrol Cost:** Distance × Fuel price ÷ Mileage
  - **Hotel Cost:** Based on destination and dates
  - **Transport:** Uber/Rapido estimates

**FR-26:** **Hotel & Commission Suggestions:**
```
Integration: Partner APIs (MakeMyTrip, Booking.com)
↓
Display:
- Hotel options with price range
- Commission info (if affiliate)
- User ratings
↓
Note: "We may earn a small commission if you book through our links."
```

**FR-27:** **Trip Expense Tracking:**
- All transactions during trip dates linked to trip_id
- Real-time comparison: Estimated vs. Actual
- Post-trip summary report

**FR-28:** **Petrol/Transport Suggestions:**
- Real-time fuel prices in destination city
- Rapido vs. Uber cost comparison
- Public transport alternatives

### 4.8. Module: Family & Person-wise Analysis

**FR-29:** **Family Dashboard:**
- Aggregated spending of all members
- Excludes transactions marked `is_personal = true`
- Category-wise breakdown by person

**FR-30:** **Person-wise Expense Analysis:**
```
Display:
Family Total: ₹50,000
├─ Dad: ₹20,000 (40%)
│  └─ Top categories: Groceries, Fuel
├─ Mom: ₹15,000 (30%)
│  └─ Top categories: Utilities, Medical
└─ Kid: ₹15,000 (30%)
   └─ Top categories: Education, Entertainment
```

**FR-31:** **Privacy Controls:**
- Users can mark specific transactions as "Personal"
- Personal transactions hidden from family view
- Aggregates still show personal amounts in "Other"

### 4.9. Module: Notifications & Alerts

**FR-32:** **Notification Types:**
1. **Reduce This:** "You've spent ₹5,000 on Dining this month. Reduce by 20% to meet budget."
2. **Cross-Cut:** "High Electronics purchase detected. Consider reducing Fuel by ₹2,000."
3. **Budget Alert:** "You've reached 80% of your Entertainment budget."
4. **Savings Exceeded:** Positive reinforcement for exceeding savings goals
5. **Recurring Prediction:** "Your Netflix subscription of ₹500 is due in 3 days."

**FR-33:** **Notification Preferences:**
- User can toggle notification types in settings
- Choose: Push, Email, or In-app only

### 4.10. Module: Reporting & Visualization

**FR-34:** **Dashboard Cards:**
1. **Safe to Spend:** Income - (Expenses + Tax + Savings Goal)
2. **Burn Rate:** Money spent per day vs. allowed daily budget
3. **This Month Summary:** Total income, expenses, savings
4. **Upcoming Predictions:** Recurring expenses in next 7 days

**FR-35:** **Charts & Analytics:**
1. **Pie Chart:** Category-wise expense breakdown
2. **Line Chart:** 30-day spending trend
3. **Bar Chart:** Month-over-month comparison
4. **Heatmap:** Day-of-week spending patterns

**FR-36:** **Time Machine (Future Prediction):**
```
Display next 3 months predicted expenses:
January 2026:
- Predicted Total: ₹35,000
- Breakdown:
  - Rent: ₹15,000 (Recurring)
  - Medical: ₹2,000 (Predicted pattern)
  - Entertainment: ₹3,500 (Average)
  - Buffer: ₹14,500
```

**FR-37:** **Transaction List Features:**
- Swipe Left → Delete
- Swipe Right → Approve (if pending)
- Color Coding:
  - Red: Expense
  - Green: Income
  - Grey: Loop/Transfer
  - Orange: Low confidence (needs review)

**FR-38:** **Export & Backup:**
- Export transactions to CSV/Excel
- Generate PDF monthly reports
- Backup data to user's cloud storage

---

## 5. Backend Logic & API Endpoints (Node.js)

### 5.1. API Structure
**Base URL:** `/api/v1`

**Authentication:** All endpoints require JWT token from Supabase Auth in header:
```
Authorization: Bearer <token>
```

### 5.2. Transaction Endpoints

#### POST `/transactions/add`
**Input:**
```json
{
  "amount": 250,
  "description": "Starbucks Coffee",
  "transaction_date": "2025-12-09T10:30:00Z",
  "type": "expense",
  "payment_method": "upi",
  "is_personal": false,
  "image_url": "https://storage.supabase.co/..." // Optional
}
```

**Process:**
1. Validate input (amount > 0, valid date, etc.)
2. Extract user_id from JWT token
3. Clean description text
4. Run AI categorization: `aiService.predict(description)`
5. Check for loop transfers: `loopDetector.scan(user_id, amount, date)`
6. Insert into `transactions` table
7. Check if triggers cross-cut logic (amount > threshold)
8. Update category spending totals
9. Check budget alerts

**Response:**
```json
{
  "status": "success",
  "transaction_id": "uuid",
  "category": {
    "id": "uuid",
    "name": "Dining",
    "confidence": 0.92
  },
  "alerts": [
    {
      "type": "budget_alert",
      "message": "You've reached 85% of Dining budget"
    }
  ],
  "suggestions": null
}
```

#### POST `/transactions/bulk-import`
**Input:** CSV file upload
**Process:** Parse CSV, validate rows, batch insert with AI categorization
**Response:** Summary with success/fail counts

#### PATCH `/transactions/:id/approve`
**Input:** `{ "action": "approve" | "reject" }`
**Process:** Update status field
**Response:** Updated transaction object

#### PATCH `/transactions/:id/recategorize`
**Input:** `{ "category_id": "uuid" }`
**Process:**
1. Update transaction category
2. Store feedback in `ai_feedback` table
3. Trigger retraining flag

#### DELETE `/transactions/:id`
**Process:** Soft delete (set deleted_at timestamp)

#### GET `/transactions`
**Query Params:**
- `start_date`, `end_date`
- `category_id`
- `status`
- `is_personal`
- `limit`, `offset`

**Response:** Paginated list of transactions

### 5.3. AI & Analytics Endpoints

#### GET `/analytics/cross-cut`
**Process:**
1. Get current month transactions
2. Identify high-value discretionary purchases
3. Calculate disposable income remaining
4. Find flexible categories with remaining budget
5. Generate suggestions

**Response:**
```json
{
  "trigger_transaction": {
    "id": "uuid",
    "amount": 25000,
    "category": "Electronics",
    "merchant": "OnePlus Store"
  },
  "remaining_disposable": 15000,
  "suggestions": [
    {
      "category": "Fuel",
      "current_spent": 4000,
      "budget": 6000,
      "suggested_reduction": 2000,
      "percentage": 33
    },
    {
      "category": "Dining",
      "current_spent": 3000,
      "budget": 5000,
      "suggested_reduction": 1500,
      "percentage": 30
    }
  ],
  "message": "Reduce Fuel by ₹2,000 and Dining by ₹1,500 to compensate for high Electronics purchase."
}
```

#### GET `/analytics/predictions`
**Process:**
1. Analyze historical data (12 months)
2. Identify recurring patterns
3. Calculate next occurrence dates
4. Estimate amounts

**Response:**
```json
{
  "next_7_days": [
    {
      "category": "Subscriptions",
      "merchant": "Netflix",
      "predicted_amount": 500,
      "predicted_date": "2025-12-12",
      "confidence": 0.95
    }
  ],
  "next_30_days": [...],
  "special_occasions": [
    {
      "occasion": "Mom's Birthday",
      "date": "2025-12-15",
      "predicted_amount": 4000,
      "last_year_amount": 3500
    }
  ]
}
```

#### GET `/analytics/spending-report`
**Query Params:** `start_date`, `end_date`, `group_by` (category/merchant/day)
**Response:** Aggregated spending data for charts

#### GET `/analytics/family-breakdown`
**Process:** Aggregate spending by family member
**Response:** Person-wise totals and category breakdowns

### 5.4. Category Endpoints

#### GET `/categories`
**Response:** List of user's categories with budgets

#### POST `/categories`
**Input:**
```json
{
  "name": "Pet Care",
  "type": "expense",
  "keywords": ["vet", "petco", "dog food"],
  "monthly_budget": 2000,
  "is_flexible": true,
  "icon": "🐶"
}
```

#### PATCH `/categories/:id`
**Input:** Fields to update
**Process:** Update category, affects future AI predictions

### 5.5. Savings & Goals Endpoints

#### GET `/savings/goals`
**Response:** List of all savings goals with progress

#### POST `/savings/goals`
**Input:**
```json
{
  "goal_name": "Emergency Fund",
  "goal_type": "long_term",
  "target_amount": 100000,
  "monthly_contribution": 5000,
  "target_date": "2026-12-31"
}
```

#### PATCH `/savings/goals/:id/contribute`
**Input:** `{ "amount": 5000 }`
**Process:** Update current_amount, check if target reached

### 5.6. Trip Planning Endpoints

#### POST `/trips`
**Input:**
```json
{
  "trip_name": "Goa Vacation",
  "destination": "Goa, India",
  "start_date": "2026-01-15",
  "end_date": "2026-01-20",
  "estimated_budget": 50000
}
```

**Process:**
1. Calculate distance from user location
2. Estimate petrol cost
3. Fetch hotel suggestions from partner APIs
4. Estimate transport costs

**Response:**
```json
{
  "trip_id": "uuid",
  "estimates": {
    "petrol": 3500,
    "hotel": 15000,
    "transport": 2000,
    "food": 8000
  },