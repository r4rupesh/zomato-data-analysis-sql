# 🍽️ Zomato Restaurant Data Analysis (SQL)

## 📌 Project Overview
This project performs end-to-end Data Cleaning, Data Transformation, and Exploratory Data Analysis (EDA) on the global [Zomato Dataset](https://github.com/SouGuit/Zomato_Dataset_Analysis/blob/main/Zomato_Dataset.csv) using SQL. The dataset includes restaurant attributes across various countries, covering details like geographic distribution, pricing, customer ratings, votes, and service offerings (online delivery & table booking).

---

## 🛠️ Database Schema
The dataset contains the following attributes:
* `RestaurantID`: Unique identifier for each restaurant
* `RestaurantName`: Name of the establishment
* `CountryCode`: Numeric code representing the country
* `City`, `Address`, `Locality`: Geographic location details
* `Cuisines`: Cuisines served (pipe-delimited or comma-separated)
* `Currency`, `Price_range`, `Average_Cost_for_two`: Pricing attributes
* `Has_Table_booking`, `Has_Online_delivery`, `Is_delivering_now`: Boolean service flags
* `Votes`, `Rating`: Customer engagement and rating metrics

---

## 🧹 Data Cleaning & Pre-processing Steps
Before running analytical queries, the following data hygiene steps were performed:
1. **Deduplication:** Removed duplicate records partitioned by `RestaurantID`.
2. **Missing Value Handling:** Replaced missing/empty `Cuisines` entries with `'Unknown'`.
3. **Rating Normalization:** Converted unrated entries (`Rating = 0`) to `NULL` to prevent skewed average calculations.
4. **Standardization:** Trimmed leading/trailing spaces across text columns and standardized boolean service flags to uppercase (`YES`/`NO`).
5. **Data Integrity:** Dropped invalid rows with negative costs and dropped uninformative columns (`Switch_to_order_menu`).

---

## 🔍 Key Analytical Questions & Business Insights

### 📍 Geographic & Market Presence
* **Q1: Which cities have the highest concentration of listed restaurants?**
  * *Insight:* Identifies the top 10 market hubs in the dataset by restaurant count.
* **Q6: What are the most expensive localities per city based on average cost for two?**
  * *Insight:* Uses window functions (`DENSE_RANK()`) to pinpoint high-end dining districts.

---

### 💰 Pricing vs. Performance
* **Q2: How do customer ratings and cost for two vary across different price ranges?**
  * *Insight:* Examines whether higher price tiers correspond to higher customer satisfaction ratings.
* **Q8: Which restaurants offer "High Rating, Low Cost" relative to their city averages?**
  * *Insight:* Finds top value-for-money dining options per city using subqueries and CTEs.

---

### 🛵 Service Offerings & Engagement
* **Q3: How does online delivery availability impact restaurant ratings and total votes?**
  * *Insight:* Evaluates if digital ordering capability improves customer engagement.
* **Q4: What advantage do table bookings offer in terms of average votes and rating?**
  * *Insight:* Measures customer engagement volume for reservation-friendly restaurants.
* **Q7: What percentage of restaurants offer both table booking and online delivery across price ranges?**
  * *Insight:* Analyzes service adoption trends across budget vs. luxury dining.

---

### 🍲 Cuisine & Brand Strategy
* **Q9: How do single-cuisine restaurants compare against multi-cuisine offerings in popularity and performance?**
  * *Insight:* Evaluates market preference for specialized vs. diverse menu offerings.
* **Q10: What are the top-rated restaurants per currency with at least 100 votes?**
  * *Insight:* Filters top-tier international establishments based on verified customer volume.

---

## 🚀 How to Run the Project
1. Clone this repository or download the SQL script: `zomato_analysis_pipeline.sql`.
2. Load the raw [Zomato Dataset](https://github.com/SouGuit/Zomato_Dataset_Analysis/blob/main/Zomato_Dataset.csv) into your preferred RDBMS (MySQL, PostgreSQL, SQL Server).
3. Execute the SQL script sequentially:
   * **Step 1:** Schema & Table Creation
   * **Step 2:** Data Cleaning & Standardizations
   * **Step 3:** Exploratory Data Analysis
