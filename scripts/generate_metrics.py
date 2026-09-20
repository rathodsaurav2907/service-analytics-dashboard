import pandas as pd
import psycopg2
from datetime import datetime, timedelta
import json

def generate_metrics_from_raw_data():
    """Generate aggregated metrics from raw service data"""
    
    # Connect to PostgreSQL
    conn = psycopg2.connect(
        host='postgres',
        database='analytics',
        user='admin',
        password='admin123'
    )
    cursor = conn.cursor()
    
    # Generate metrics for last 30 days
    for days_back in range(0, 30):
        metric_date = datetime.now().date() - timedelta(days=days_back)
        
        # Query daily metrics
        cursor.execute("""
            SELECT 
                service_id,
                SUM(total_requests) as total_requests,
                SUM(completed_requests) as completed_requests,
                SUM(failed_requests) as failed_requests,
                ROUND(AVG(avg_resolution_time_minutes)) as avg_resolution_time,
                ROUND(AVG(avg_customer_satisfaction)::NUMERIC, 2) as avg_satisfaction,
                SUM(revenue) as revenue
            FROM daily_metrics
            WHERE metric_date = %s
            GROUP BY service_id
        """, (metric_date,))
        
        results = cursor.fetchall()
        print(f"Date: {metric_date}")
        print(f"  - Processed {len(results)} services")
        for row in results:
            print(f"    {row[0]}: {row[1]} requests, {row[2]} completed, {row[3]} failed")
    
    conn.close()
    print("\nMetrics generation completed successfully")

if __name__ == '__main__':
    generate_metrics_from_raw_data()
