# Service Analytics Dashboard

[![CI/CD](https://github.com/rathodsaurav2907/service-analytics-dashboard/actions/workflows/ci.yml/badge.svg)](https://github.com/rathodsaurav2907/service-analytics-dashboard/actions/workflows/ci.yml)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](./docker-compose.yml)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?logo=jupyter&logoColor=white)](https://jupyter.org)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](https://python.org)

A cloud data warehouse, automated metric aggregation pipeline, and Jupyter exploratory environment for roadside and operational services, powered by PostgreSQL and Python.

Part of the **[Microservices & ML Data Platform Ecosystem](../ECOSYSTEM.md)**.

---

## 🌟 Overview

The Service Analytics Dashboard models and extracts behavioral trends and operational health metrics from transactional systems like **[PunctureWala](../puncturewala/)**. It aggregates bookings, revenue, cancellations, and technician response times into analytical views, feeding feature vectors to downstream machine learning services like the **[Customer Churn Predictor](../customer-churn-predictor/)**.

---

## 🛠️ Tech Stack

* **Database:** PostgreSQL 17 (Dimensional modeling, materialized views, JSONB metrics)
* **Analytics Environment:** Jupyter Scipy Notebook (Python 3.11, Pandas, Matplotlib, Seaborn)
* **Database Driver / ORM:** SQLAlchemy, Psycopg2-binary
* **Automation:** Python metric generation scripts (`scripts/generate_metrics.py`)
* **Containerization:** Docker & Docker Compose

---

## 🚀 Quick Start

### 1. Using Docker (Recommended)

```bash
# Start PostgreSQL (port 5434) and Jupyter Notebook (port 8884)
docker compose up --build -d

# Open Jupyter in your browser:
# http://localhost:8884/?token=change-me
```

PostgreSQL automatically initializes schemas and seeds from `database/init.sql` and `database/seed_data.sql` on first boot.

### 2. Running Locally

```bash
# Initialize PostgreSQL schema & seed data
psql -U analytics -d service_analytics -f database/init.sql
psql -U analytics -d service_analytics -f database/seed_data.sql

# Install Python requirements and launch Jupyter
pip install sqlalchemy psycopg2-binary pandas matplotlib seaborn jupyter
jupyter notebook notebooks/
```

---

## 📊 Analytics Schema & Views

* **`daily_service_metrics`**: Service counts, revenue, average resolution time, cancellations.
* **`technician_performance_daily`**: Active hours, completed tickets, user ratings.
* **`v_service_summary`**: High-level aggregated KPIs by service category.
* **`v_peak_demand_hours`**: Hourly distribution of demand spikes for dispatch capacity planning.

---

## 🧪 Testing & Validation

```bash
psql -U analytics -d service_analytics -f tests/test_queries.sql
```
Validates data integrity, constraint validation, aggregation accuracy, and non-null metric checks.
