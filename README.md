# HousekeepingBook

This is my personal shared housekeeping book service for me and my partner.
I will use it to track my and my partner's expenses and income.

The key feature that I want is to be able to share
the housekeeping book with my partner.
So that we can both add and edit records.

## Pages

### Home (Dashboard)

This should be the default page. It contains the following items:

- Total Balance
- Total Expense
- Total Income
- Monthly Expense
- Monthly Income
- Yearly Expense
- Yearly Income
- Recent 10 Records
- Daily Expense Chart
- 5 categories with the highest expense

### Record List Page

I think it would be great to show a calendar on this page.
The calendar should highlight the days that have records.
Clicking on a day should show the records of that day.

There should be a button to add a new record.

The record list should be paginated.

Also, there should be a search bar to search records.

I need one more feature, which is to import and export records as a CSV file.

### Record Detail Page

- Date
- Category
- Amount
- Description
- Edit Button
- Delete Button
- Back Button
- Next Button
- Previous Button

### Monthly Report Page

This page should show a monthly report of the selected month.
It contains the following items:

- Monthly Total Balance
- Monthly Total Expense
- Monthly Total Income

I want to add a feature that allows users to select a month and
then show the monthly report of that month.

Also, it would be grate to make a budget for each month and
show the budget on this page.

### Yearly Report Page

This page should show a yearly report of the selected year.
It contains the following items:

- Yearly Total Balance
- Yearly Total Expense
- Yearly Total Income

### Navigation

The navigation bar is on the top of the page. It contains the following items:

- Home
- Record List
- Monthly Report
- Yearly Report

## Design

## Data Model

### User

The user who spends money or earns money.

- id: int
- name: string
- email: string
- created_at: datetime
- updated_at: datetime

### Category

Categories are used to classify records. There are tree structures for categories.
That means a category can have a parent category and child categories.

The top level category is the root category.

Some level of categories are more important, because I will structure the
report page and dashboard page according to those categories.

Also, I want a feature that allows users to make a budget for each category.

- id: int
- name: string
- parent_id: int
- type: string (expense or income or saving)
- created_at: datetime
- updated_at: datetime

### Tag

This is a tag that can be attached to a record.
Tags will be useful when searching records.

- id: int
- name: string
- created_at: datetime
- updated_at: datetime

### Record

- id: int
- subject_id::User: int
- category_id::Category: int
- amount: int
- description: string
- date: datetime
- created_at: datetime
- updated_at: datetime
- tag_ids::Tag[]: int[]

### Budget

Budgets are used to set a budget for each category for each month or year.

- id: int
- category_id::Category: int
- type: string (income or expense)
- amount: int
- created_at: datetime
- updated_at: datetime
- year: int
- month: int
