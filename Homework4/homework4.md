## Module 4 Homework
For this homework, you will need the following datasets

- [Green Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/green)
- [Yellow Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/yellow)
- [For Hire Vehicle dataset (2019)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv)

## Index

- **01: Understanding dbt model resolution**
- **02: dbt Variables & Dynamics  models**
- **03: dbt Data Lineage & Execution**
- **04: dbt Micros and Jinja**
- **05: Taxi Quarterly Revenue Growth**
- **06: Taxi Quartely Revenue Growth**
- **07: Top #Nth longest P90 travel time Location for FHV**


---


## Q1: Understanding dbt model resolution

Provided you've got the following sources.yaml

> version: 2

sources:
  - name: raw_nyc_tripdata
    database: "{{ env_var('DBT_BIGQUERY_PROJECT', 'dtc_zoomcamp_2025') }}"
    schema:   "{{ env_var('DBT_BIGQUERY_SOURCE_DATASET', 'raw_nyc_tripdata') }}"
    tables:
      - name: ext_green_taxi
      - name: ext_yellow_taxi


> **select * from myproject.my_nyc_tripdata.ext_green_taxi**


## Q2: dbt Variables & Dynamic model

Say you have to modify the following dbt_model (fct_recent_taxi_trips.sql) to enable Analytics Engineers to dynamically control the date range.


- In development, you want to process only **the last 7 days of trips**
- In production, you need to process **the last 30 days** for analytics

> **select *
from {{ ref('fact_taxi_trips') }}
where pickup_datetime >= CURRENT_DATE - INTERVAL '30' DAY**

What would you change to accomplish that in a such way that command line arguments takes precedence over ENV_VARs, which takes precedence over DEFAULT value?

> **Update the WHERE clause to pickup_datetime >= CURRENT_DATE - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY**

## Q3: dbt Data Lineage and Execution

Considering the data lineage below and that taxi_zone_lookup is the only materialization build (from a .csv seed file):

![dbt](/Homework4/homework_q2.png)

Select the option that does NOT apply for materializing fct_taxi_monthly_zone_revenue:

> **dbt run --select models/staging/+**

## Q4: dbt Macros and Jinja

Consider you're dealing with sensitive data (e.g.: PII), that is only available to your team and very selected few individuals, in the raw layer of your DWH (e.g: a specific BigQuery dataset or PostgreSQL schema),

- Among other things, you decide to obfuscate/masquerade that data through your staging models, and make it available in a different schema (a staging layer) for other Data/Analytics Engineers to explore

- And optionally, yet another layer (service layer), where you'll build your dimension (dim_) and fact (fct_) tables (assuming the Star Schema dimensional modeling) for Dashboarding and for Tech Product Owners/Managers.

You decide to make a macro to wrap a logic around it:

> {% macro resolve_schema_for(model_type) -%}

    {%- set target_env_var = 'DBT_BIGQUERY_TARGET_DATASET'  -%}
    {%- set stging_env_var = 'DBT_BIGQUERY_STAGING_DATASET' -%}

    {%- if model_type == 'core' -%} {{- env_var(target_env_var) -}}
    {%- else -%}                    {{- env_var(stging_env_var, env_var(target_env_var)) -}}
    {%- endif -%}

{%- endmacro %}

And use on your staging, dim_ and fact_ models as:

> **When using staging, it materializes in the dataset defined in DBT_BIGQUERY_STAGING_DATASET, or defaults to DBT_BIGQUERY_TARGET_DATASET**

## SQL Series

Alright, in module 1, you had sql refresher. so now let's build on top of that with some serious SQL.

These are not meant to be easy - but they'll boost your SQL and Analytics skills to the next level.
So, without any further do, let's get started...

You might want to add some new dimensions year (e.g.: 2019, 2020), quarter (1, 2, 3, 4), year_quarter (e.g.: 2019/Q1, 2019-Q2), and month (e.g.: 1, 2, ..., 12), extracted from pickup_datetime, to your fct_taxi_trips OR dim_taxi_trips.sql models to facilitate filtering your queries

## Q5: Taxi Quarterly Revenue Growth

1. Create a new model fct_taxi_trips_quarterly_revenue.sql

- First, we will go to dbt and edit the file dm_monthly_zone_revenue by adding new date formats, to help our calculations. Don't forget to add the group by at the end.

> {{ config(materialized='table') }}

with trips_data as (
    select *,
        EXTRACT(YEAR FROM pickup_datetime) AS year,
        EXTRACT(QUARTER FROM pickup_datetime) AS quarter,
        EXTRACT(MONTH FROM pickup_datetime) AS month,
        CONCAT(EXTRACT(YEAR FROM pickup_datetime), '/Q', EXTRACT(QUARTER FROM pickup_datetime)) AS year_quarter

    from {{ ref('fact_trips') }}
)
    select 
    -- Reveneue grouping
    pickup_zone as revenue_zone,
    {{ dbt.date_trunc("month", "pickup_datetime") }} as revenue_month,

    service_type,

    -- Add new date components
    year,
    quarter,
    month,
    year_quarter,

    -- Revenue calculation
    sum(fare_amount) as revenue_monthly_fare,
    sum(extra) as revenue_monthly_extra,
    sum(mta_tax) as revenue_monthly_mta_tax,
    sum(tip_amount) as revenue_monthly_tip_amount,
    sum(tolls_amount) as revenue_monthly_tolls_amount,
    sum(ehail_fee) as revenue_monthly_ehail_fee,
    sum(improvement_surcharge) as revenue_monthly_improvement_surcharge,
    sum(total_amount) as revenue_monthly_total_amount,

    -- Additional calculations
    count(tripid) as total_monthly_trips,
    avg(passenger_count) as avg_monthly_passenger_count,
    avg(trip_distance) as avg_monthly_trip_distance

    from trips_data
    group by 1,2,3, 4, 5, 6, 7

- The, we will go to dbt, create a file fct_taxi_trips_quarterly_revenue.sql inside models/core directory.

- At the beginning of the file, set the materialization type:

> WITH quarterly_revenue AS (
    SELECT
        year,
        quarter,
        year_quarter,
        service_type,
        SUM(revenue_monthly_total_amount) AS total_revenue
    FROM {{ ref('dm_monthly_zone_revenue') }}
    GROUP BY 1, 2, 3, 4
),

2. Compute the Quarterly Revenues for each year for based on total_amount 3. Compute the Quarterly YoY (Year-over-Year) revenue growth.

Append to the file **fct_taxi_trips_quarterly_revenue.sql:**

> yoy_revenue AS (
    SELECT
        qr.year,
        qr.quarter,
        qr.year_quarter,
        qr.service_type,
        qr.total_revenue,
        LAG(qr.total_revenue) OVER (
            PARTITION BY qr.service_type, qr.quarter
            ORDER BY qr.year
        ) AS prev_year_revenue,
        ROUND(
            (qr.total_revenue - LAG(qr.total_revenue) OVER (
                PARTITION BY qr.service_type, qr.quarter
                ORDER BY qr.year
            )) / NULLIF(LAG(qr.total_revenue) OVER (
                PARTITION BY qr.service_type, qr.quarter
                ORDER BY qr.year
            ), 0) * 100, 2
        ) AS yoy_growth
    FROM quarterly_revenue qr
)

SELECT
    year,
    quarter,
    year_quarter,
    service_type,
    total_revenue,         -- Aggregated revenue (correct comparison)
    prev_year_revenue,     -- Revenue from the same quarter in the previous year
    yoy_growth             -- Correct YoY Growth after aggregation
FROM yoy_revenue

> **green: {best: 2020/Q1, worst: 2020/Q2}, yellow: {best: 2020/Q1, worst: 2020/Q2}**

## Q6:  P97/P95/P90 Taxi Monthly Fare

1. Create a new model fct_taxi_trips_monthly_fare_p95.sql
2. Filter out invalid entries (fare_amount > 0, trip_distance > 0, and payment_type_description in ('Cash', 'Credit Card'))
3. Compute the continous percentile of fare_amount partitioning by service_type, year and and month

- e.g.: In 2020/Q1, Green Taxi had -12.34% revenue growth compared to 2019/Q1
e.g.: In 2020/Q4, Yellow Taxi had +34.56% revenue growth compared to 2019/Q4
- Considering the YoY Growth in 2020, which were the yearly quarters with the best (or less worse) and worst results for green, and yellow

Now, what are the values of p97, p95, p90 for Green Taxi and Yellow Taxi, in April 2020?

> **green: {p97: 55.0, p95: 45.0, p90: 26.5}, yellow: {p97: 31.5, p95: 25.5, p90: 19.0}**

## Q7: Top #Nth longest P90 travel time Location for FHV

Prerequisites:

- Create a staging model for FHV Data (2019), and DO NOT add a deduplication step, just filter out the entries where where dispatching_base_num is not null
- Create a core model for FHV Data (dim_fhv_trips.sql) joining with dim_zones. Similar to what has been done here
- Add some new dimensions year (e.g.: 2019) and month (e.g.: 1, 2, ..., 12), based on pickup_datetime, to the core model to facilitate filtering for your queries

Now

1. Create a new model fct_fhv_monthly_zone_traveltime_p90.sql
2. For each record in dim_fhv_trips.sql, compute the timestamp_diff in seconds between dropoff_datetime and pickup_datetime - we'll call it trip_duration for this exercise
3. Compute the continous p90 of trip_duration partitioning by year, month, pickup_location_id, and dropoff_location_id.


For the Trips that respectively started from Newark Airport, SoHo, and Yorkville East, in November 2019, what are dropoff_zones with the 2nd longest p90 trip_duration ?

> **LaGuardia Airport, Chinatown, Garment District**

WITH ranked_trips AS (
    SELECT 
        pz.zone AS pickup_zone,
        dz.zone AS dropoff_zone,
        t.travel_time_p90,
        ROW_NUMBER() OVER (
            PARTITION BY pz.zone
            ORDER BY t.travel_time_p90 DESC
        ) AS trip_rank
    FROM charged-scholar-446408-g1.dbt_okamara.fct_fhv_monthly_zone_traveltime_p90 t
    JOIN charged-scholar-446408-g1.dbt_okamara.dim_zones pz ON t.pickup_locationid = pz.locationid
    JOIN charged-scholar-446408-g1.dbt_okamara.dim_zones dz ON t.dropoff_locationid = dz.locationid
    WHERE 
        t.year = 2019 
        AND t.month = 11
        AND pz.zone IN ('Newark Airport', 'SoHo', 'Yorkville East')
)

SELECT 
    pickup_zone, 
    dropoff_zone, 
    travel_time_p90
FROM ranked_trips
WHERE trip_rank = 2;


![Q7](/Homework4/Screenshot.png)





