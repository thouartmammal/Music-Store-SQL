# Music Store SQL Analysis

## Overview

This project demonstrates **SQL-based data analysis** on a music store database, emphasizing **relational database management, advanced query techniques, and business intelligence insights**. 

Key highlights:

- **Database Design & Integrity:** Enforced **primary keys (PK) and foreign keys (FK)** across all tables to ensure data consistency.  
- **Advanced SQL Techniques:** Utilized **joins, window functions (`LAG`, `RANK`), aggregations, and conditional statements** for detailed analysis.  
- **Customer Analytics:** Conducted **churn analysis, customer lifetime value (CLV) calculation**, and identified each customer's **top 3 artists**.  
- **Revenue & Trend Analysis:** Calculated **monthly and yearly revenue trends**, genre popularity, and revenue by artist.  
- **Behavioral Insights:** Identified **genre-loyal customers** to support targeted marketing and upselling strategies.  
- **Reusable Views:** Created **views** like `ann_frequency` to **simplify complex queries**, track customer behavior trends, and enable efficient reporting.

The goal is to demonstrate how **SQL and data analysis skills** can extract actionable insights for **customer retention, sales optimization, and business strategy**.

---

## Project Structure
Music-Store-SQL/
├─ music_store.sql # Main SQL file with table creation, PKs/FKs, and analysis queries
├─ README.md # This file


---

## Database Tables
The project uses the dataset from: https://github.com/rishabhnmishra/SQL_Music_Store_Analysis?tab=readme-ov-file
The project uses the following tables:

- `artist` – Stores artist information  
- `album2` – Albums for each artist  
- `track` – Tracks in each album  
- `invoice` – Customer purchases  
- `invoice_line` – Detailed line items for each invoice  
- `customer` – Customer information  
- `genre` – Music genres  
- `media_type` – Type of media (MP3, CD, etc.)  
- `playlist` – Playlists created by users  
- `playlist_track` – Many-to-many relationship between playlists and tracks  
- `employee` – Employees supporting customers  

All tables have **primary keys** and appropriate **foreign key constraints**.

---

## Analysis Included

1. **Revenue by Genre**
   - Identifies the most profitable genres and tracks for the store.

2. **Customer Churn**
   - Calculates yearly purchase frequency for each customer.  
   - Uses `LAG()` to determine if purchase frequency decreased or stayed the same.  
   - Creates a view `ann_frequency` for easy tracking.

3. **Customer Lifetime Value (CLV) & Top Artists**
   - Computes total spend per customer per artist.  
   - Identifies the **top 3 artists per customer** using window functions.

4. **Monthly Revenue Trends**
   - Tracks revenue month-over-month using `LAG()` to identify growth trends.

5. **Genre-Loyal Customers**
   - Detects customers who consistently buy from a single genre.  
   - Useful for **targeted marketing and upselling**.

---

## How to Use

1. **Load the SQL file** into your MySQL database:

```bash
mysql -u your_user -p your_database < music_store.sql

2. Run queries directly in MySQL Workbench or any MySQL client.
3. Views like ann_frequency can be queried directly.

