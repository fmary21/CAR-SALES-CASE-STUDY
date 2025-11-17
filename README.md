

# 🚗 Bright Motors Car Sales Analysis

## 📌 Project Summary

This repository contains a complete data analytics case study for Bright Motors, aimed at supporting the newly appointed Head of Sales. Using historical car sales data, we uncover insights to guide dealership expansion, sales optimization, and inventory strategy.

---

## 🎯 Objectives

- Identify top-performing car makes and models by revenue
- Explore relationships between price, mileage, and year of manufacture
- Analyze regional sales performance
- Detect emerging customer purchasing trends
- Recommend strategies to improve profitability and efficiency

---

## 🧰 Tools & Technologies

| Category              | Tools Used                                  |
|-----------------------|----------------------------------------------|
| Data Processing       | Snowflake, Databricks, MySQL Workbench       |
| Data Visualization    | Power BI, Excel, Google Looker Studio        |
| Presentation Design   | Canva, Microsoft PowerPoint                  |
| Planning & Architecture | Miro, Figma                                |

---

## 📁 Repository Structure


---

## 🔄 Workflow Overview

### 1. Planning & Architecture
- Miro board outlining data flow: source → ETL → storage → analysis → presentation

### 2. Data Processing (SQL)
- Load CSV into Snowflake
- Clean and transform data:
  - Convert price strings to numeric
  - Create `total_revenue` and `profit_margin` columns
  - Categorize cars by margin tiers
  - Group by make, model, year, region, fuel type

### 3. Data Analysis & Visualization
- Export processed data to Excel or connect Power BI
- Build interactive dashboards with slicers (region, fuel type, year)
- Key metrics: revenue trends, regional performance, fuel type distribution

### 4. Presentation
- Summarize insights and recommendations
- Design visually engaging slides for executive review



## 📦 Deliverables

- ✅ Miro Architecture Diagram (`planning/`)
- ✅ Processed Dataset (`processed/car_sales_processed.xlsx`)
- ✅ SQL Script (`sql/car_sales_queries.sql`)
- ✅ Final Presentation (`presentation/BrightMotors_Presentation.pdf`)



## 📝 Best Practices

- Clean all numeric fields (remove commas, convert to float)
- Use consistent column naming conventions
- Annotate dashboards with brief insights
- Keep presentation concise and visually compelling



## 📬 Contact

For questions or collaboration, feel free to reach out via GitHub Issues or Discussions.


