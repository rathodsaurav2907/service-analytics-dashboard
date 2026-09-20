-- PostgreSQL Schema for Service Analytics Dashboard

CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    service_id VARCHAR(50) UNIQUE NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE daily_metrics (
    id SERIAL PRIMARY KEY,
    service_id VARCHAR(50) NOT NULL,
    metric_date DATE NOT NULL,
    total_requests INT DEFAULT 0,
    completed_requests INT DEFAULT 0,
    failed_requests INT DEFAULT 0,
    avg_resolution_time_minutes INT DEFAULT 0,
    avg_customer_satisfaction NUMERIC(3,2) DEFAULT 0,
    revenue NUMERIC(12,2) DEFAULT 0,
    peak_hour INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(service_id),
    UNIQUE(service_id, metric_date)
);

CREATE TABLE kpis (
    id SERIAL PRIMARY KEY,
    kpi_date DATE NOT NULL,
    total_daily_volume INT DEFAULT 0,
    avg_resolution_time INT DEFAULT 0,
    customer_satisfaction_score NUMERIC(3,2) DEFAULT 0,
    revenue_by_region JSONB,
    top_service VARCHAR(100),
    success_rate NUMERIC(5,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(kpi_date)
);

-- Indexes for query optimization
CREATE INDEX idx_daily_metrics_service_date ON daily_metrics(service_id, metric_date DESC);
CREATE INDEX idx_daily_metrics_date ON daily_metrics(metric_date DESC);
CREATE INDEX idx_kpis_date ON kpis(kpi_date DESC);
CREATE INDEX idx_services_status ON services(status);

-- Create views for common analytics queries

CREATE VIEW service_performance_30days AS
SELECT 
    s.service_name,
    DATE_TRUNC('day', dm.metric_date)::DATE as date,
    dm.total_requests,
    dm.completed_requests,
    dm.failed_requests,
    ROUND(CAST(dm.completed_requests AS NUMERIC) / NULLIF(dm.total_requests, 0) * 100, 2) as success_rate,
    dm.avg_resolution_time_minutes,
    dm.avg_customer_satisfaction,
    dm.revenue
FROM daily_metrics dm
JOIN services s ON dm.service_id = s.service_id
WHERE dm.metric_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY dm.metric_date DESC, s.service_name;

CREATE VIEW revenue_by_region_daily AS
SELECT 
    kpi_date,
    kpis.revenue_by_region,
    SUM(CAST(kpis.revenue_by_region->>'North' AS NUMERIC)) as north_revenue,
    SUM(CAST(kpis.revenue_by_region->>'South' AS NUMERIC)) as south_revenue,
    SUM(CAST(kpis.revenue_by_region->>'East' AS NUMERIC)) as east_revenue,
    SUM(CAST(kpis.revenue_by_region->>'West' AS NUMERIC)) as west_revenue
FROM kpis
WHERE kpi_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY kpi_date, kpis.revenue_by_region
ORDER BY kpi_date DESC;
