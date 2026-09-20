# Service Analytics Dashboard

Python/Jupyter and PostgreSQL environment for the PunctureWala-style service analytics project. It supports SQL analysis, Pandas EDA, and Power BI extracts.

Run `docker compose up --build`, then open `http://localhost:8884` and use the token from `.env`/the compose file. Place schema and seed SQL in `sql/`, source data in `data/`, and analysis notebooks in `notebooks/`.

## Suggested milestones

- demand, peak-hour, provider-performance, customer-behaviour, and revenue KPIs
- data-quality checks and reproducible SQL transformations
- export clean summary tables for a Power BI dashboard
