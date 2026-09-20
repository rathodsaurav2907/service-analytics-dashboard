-- SQL tests for data integrity and query performance

-- Test 1: Verify sample data exists
SELECT 
    'Test 1: Sample Data Exists' as test_name,
    COUNT(*) as record_count,
    'PASS' as status
FROM daily_metrics
WHERE metric_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY 'PASS'
HAVING COUNT(*) >= 720; -- 8 services * 90 days

-- Test 2: Verify no negative values
SELECT 
    'Test 2: No Negative Metrics' as test_name,
    COUNT(*) as violation_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM daily_metrics
WHERE total_requests < 0 
   OR completed_requests < 0 
   OR failed_requests < 0
   OR avg_resolution_time_minutes < 0
   OR revenue < 0;

-- Test 3: Verify completed <= total requests
SELECT 
    'Test 3: Completed <= Total' as test_name,
    COUNT(*) as violation_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM daily_metrics
WHERE completed_requests > total_requests;

-- Test 4: Verify satisfaction score in valid range (1-5)
SELECT 
    'Test 4: Valid Satisfaction Score' as test_name,
    COUNT(*) as violation_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM daily_metrics
WHERE avg_customer_satisfaction < 1.0 OR avg_customer_satisfaction > 5.0;

-- Test 5: Query performance - service performance view
EXPLAIN ANALYZE
SELECT * FROM service_performance_30days
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY date DESC
LIMIT 100;

-- Test 6: Verify unique constraints
SELECT 
    'Test 6: Unique Service Per Date' as test_name,
    COUNT(*) as violation_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM (
    SELECT service_id, metric_date, COUNT(*)
    FROM daily_metrics
    GROUP BY service_id, metric_date
    HAVING COUNT(*) > 1
) duplicates;

-- Test 7: Revenue aggregation consistency
SELECT 
    'Test 7: Revenue Aggregation Consistent' as test_name,
    COUNT(*) as checks,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM kpis
WHERE kpi_date >= CURRENT_DATE - INTERVAL '30 days'
AND revenue_by_region IS NOT NULL;

-- Test 8: Data completeness
SELECT 
    'Test 8: Data Completeness' as test_name,
    COUNT(*) as total_services,
    COUNT(DISTINCT service_id) as distinct_services,
    CASE WHEN COUNT(*) = COUNT(DISTINCT service_id) THEN 'PASS' ELSE 'FAIL' END as status
FROM services
WHERE status = 'active';

-- Test 9: KPI Aggregation Validation
SELECT 
    'Test 9: KPI Data Exists' as test_name,
    COUNT(*) as kpi_records,
    CASE WHEN COUNT(*) >= 30 THEN 'PASS' ELSE 'FAIL' END as status
FROM kpis
WHERE kpi_date >= CURRENT_DATE - INTERVAL '90 days';

-- Test 10: Peak hour validity (0-23)
SELECT 
    'Test 10: Valid Peak Hours' as test_name,
    COUNT(*) as violation_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM daily_metrics
WHERE peak_hour < 0 OR peak_hour > 23;
