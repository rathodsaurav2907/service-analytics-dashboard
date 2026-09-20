-- Seed data for 90 days of service metrics

INSERT INTO services (service_id, service_name, category, status) VALUES
('SVC-001', 'Premium Support', 'Support', 'active'),
('SVC-002', 'Onboarding', 'Implementation', 'active'),
('SVC-003', 'System Maintenance', 'Operations', 'active'),
('SVC-004', 'Bug Fixes', 'Development', 'active'),
('SVC-005', 'Training', 'Education', 'active'),
('SVC-006', 'Consulting', 'Advisory', 'active'),
('SVC-007', 'Integration', 'Technical', 'active'),
('SVC-008', 'Performance Tuning', 'Optimization', 'active');

-- Generate 90 days of daily metrics
DO $$ 
DECLARE
    v_date DATE := CURRENT_DATE - INTERVAL '90 days';
    v_service_id VARCHAR;
    v_total_requests INT;
    v_completed INT;
    v_failed INT;
    v_resolution_time INT;
    v_satisfaction NUMERIC;
    v_revenue NUMERIC;
    v_peak_hour INT;
BEGIN
    WHILE v_date <= CURRENT_DATE LOOP
        FOREACH v_service_id IN ARRAY ARRAY['SVC-001', 'SVC-002', 'SVC-003', 'SVC-004', 'SVC-005', 'SVC-006', 'SVC-007', 'SVC-008']
        LOOP
            v_total_requests := (RANDOM() * 200 + 50)::INT;
            v_completed := (v_total_requests * (0.85 + RANDOM() * 0.1))::INT;
            v_failed := v_total_requests - v_completed;
            v_resolution_time := (RANDOM() * 120 + 20)::INT;
            v_satisfaction := (RANDOM() * 2 + 3.5)::NUMERIC;
            v_revenue := (RANDOM() * 5000 + 1000)::NUMERIC;
            v_peak_hour := (RANDOM() * 23)::INT;
            
            INSERT INTO daily_metrics (service_id, metric_date, total_requests, completed_requests, failed_requests, 
                                       avg_resolution_time_minutes, avg_customer_satisfaction, revenue, peak_hour)
            VALUES (v_service_id, v_date, v_total_requests, v_completed, v_failed, 
                    v_resolution_time, v_satisfaction, v_revenue, v_peak_hour);
        END LOOP;
        
        -- Insert daily KPI aggregates
        INSERT INTO kpis (kpi_date, total_daily_volume, avg_resolution_time, customer_satisfaction_score, 
                          revenue_by_region, top_service, success_rate)
        SELECT 
            v_date,
            SUM(dm.total_requests),
            ROUND(AVG(dm.avg_resolution_time_minutes)),
            ROUND(AVG(dm.avg_customer_satisfaction)::NUMERIC, 2),
            jsonb_build_object(
                'North', ROUND((SUM(dm.revenue) * 0.25)::NUMERIC, 2),
                'South', ROUND((SUM(dm.revenue) * 0.25)::NUMERIC, 2),
                'East', ROUND((SUM(dm.revenue) * 0.30)::NUMERIC, 2),
                'West', ROUND((SUM(dm.revenue) * 0.20)::NUMERIC, 2)
            ),
            (SELECT dm2.service_id FROM daily_metrics dm2 WHERE dm2.metric_date = v_date 
             ORDER BY dm2.completed_requests DESC LIMIT 1),
            ROUND(CAST(SUM(dm.completed_requests) AS NUMERIC) / NULLIF(SUM(dm.total_requests), 0) * 100, 2)
        FROM daily_metrics dm
        WHERE dm.metric_date = v_date
        ON CONFLICT (kpi_date) DO NOTHING;
        
        v_date := v_date + INTERVAL '1 day';
    END LOOP;
END $$;

-- Verify data
SELECT COUNT(*) as total_services FROM services;
SELECT COUNT(*) as total_daily_metrics FROM daily_metrics;
SELECT COUNT(*) as total_kpis FROM kpis;
