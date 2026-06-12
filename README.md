# 📊 Job Market Intelligence Dashboard — Data & Tech Roles (2020–2024)

> End-to-end data analytics project analyzing global tech job market trends  
> with a dedicated India market spotlight  
> **Tools:** Python · SQL · Looker Studio · scikit-learn

---

## 🔍 Project Overview

This project analyzes **9,355 job postings** across **82 countries** to answer:
- Which data roles have highest demand and compensation?
- How has the job market grown from 2020–2024?
- Where does India stand in the global data job market?
- What salary can a professional expect given their role and experience?

---

## 📁 Project Structure
job-market-india-analysis/

├── job_market_analysis_india.ipynb   ← Main analysis notebook

├── sql/

│   └── analysis_queries.sql          ← 7 SQL queries (CTEs, Window Functions, JOINs)

├── data/

│   └── cleaned/

│       └── dashboard_data.csv        ← Cleaned dataset for dashboard

├── reports/

│   └── insight_report.txt            ← Auto-generated findings report

└── charts/                           ← All 10 visualizations
---

## 🔑 Key Findings

| Finding | Insight |
|---|---|
| 🥇 Top Role | Data Scientist — 23.6% of all postings |
| 💰 Highest Paying | ML Engineer — $170,000 median salary |
| 📈 Experience Premium | Entry → Senior = **107.7% salary increase** |
| 🌐 Remote Work | 41.9% of all data roles are fully remote |
| 🇮🇳 India Median | $50,000 USD vs $140,000 global median |
| 📅 Market Growth | 192% more postings in 2023–24 vs 2020–22 |

---

## 🛠️ Technical Stack

**Python Libraries:** pandas, numpy, matplotlib, seaborn, plotly, scikit-learn, scipy  
**SQL:** SQLite — SELECT, GROUP BY, CASE WHEN, CTEs, Window Functions (RANK, LAG), JOINs  
**ML:** Random Forest Regressor + Linear Regression (salary prediction)  
**Dashboard:** Looker Studio (Google)  
**Dataset:** [Jobs in Data — Kaggle](https://www.kaggle.com/datasets/hummaamqaasim/jobs-in-data)

---

## 📊 Dashboard

🔗 **[View Live Dashboard →](https://datastudio.google.com/reporting/7e0ab137-1c7d-4c8e-8b36-e09862903b0c)**




## 🤖 ML Model — Salary Predictor

Built a Random Forest model to predict salary based on role, experience, work setting, and company size.

| Model | MAE (USD) | R² Score |
|---|---|---|
| Linear Regression | $46,382 | 0.161 |
| Random Forest | $43,996 | 0.250 |

**Sample Predictions (2024):**
- Entry-level Data Analyst · Remote · Medium company → **$79,784**
- Senior ML Engineer · Hybrid · Large company → **$77,529**
- Mid-level Data Scientist · In-person · Small company → **$101,024**

*Model note: R² of 0.25 reflects dataset limitations (no skills/city/years-of-experience columns).  
A stronger feature set would significantly improve predictive power — documented as a finding.*

---

## 🗃️ SQL Skills Demonstrated

```sql
-- Example: Window function ranking top roles per experience level
WITH ranked_roles AS (
    SELECT experience_level, role_category,
           ROUND(AVG(salary_in_usd), 0) AS avg_salary,
           RANK() OVER (
               PARTITION BY experience_level
               ORDER BY AVG(salary_in_usd) DESC
           ) AS salary_rank
    FROM jobs_global
    GROUP BY experience_level, role_category
)
SELECT * FROM ranked_roles WHERE salary_rank <= 3;
```

---

## ⚠️ Limitations & Honest Notes

- India sample is only 15 rows (0.2% of dataset) — conclusions are directional, not definitive
- Dataset is US-dominated (majority of postings)
- ML model R² = 0.25 — salary is influenced by factors not present in this dataset
- Forecast assumes linear trend continuation

---

## 👤 Author

Nagireddy Prameela Durga 
Aspiring Data Analyst | Python · SQL · Looker Studio  

