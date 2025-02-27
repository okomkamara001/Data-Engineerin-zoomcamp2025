## Module 4 Homework
For this homework, you will need the following datasets

- [Green Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/green)
- [Yellow Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/yellow)
- [For Hire Vehicle dataset (2019)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv)


## Q1: Understanding dbt  model resolution

Provided you've got the following source.yaml

> version: 2

sources:
  - name: raw_nyc_tripdata
    database: "{{ env_var('DBT_BIGQUERY_PROJECT', 'dtc_zoomcamp_2025') }}"
    schema:   "{{ env_var('DBT_BIGQUERY_SOURCE_DATASET', 'raw_nyc_tripdata') }}"
    tables:
      - name: ext_green_taxi
      - name: ext_yellow_taxi
      `

with the env variables setup where **dbt** runs

> export DBT_BIGQUERY_PROJECT=myproject
export DBT_BIGQUERY_DATASET=my_nyc_tripdata

What does the this .sql model compile to?

> select * from dtc_zoomcamp_2025.raw_nyc_tripdata.ext_green_taxi

## Q2: dbt Variables & Dynamic model

Say you have to modify the following dbt_model (fct_recent_taxi_trips.sql) to enable Analytics Engineers to dynamically control the date range.

- In development, you want to process only **the last 7 days of trips**
- In production, you need to process **the last 30 days** for analytics

> **select *
from {{ ref('fact_taxi_trips') }}
where pickup_datetime >= CURRENT_DATE - INTERVAL '30' DAY**

What would you change to accomplish that in a such way that command line arguments takes precedence over ENV_VARs, which takes precedence over DEFAULT value?

> 

## Q3: dbt Data Lineage and Execution

Considering the data lineage below and that taxi_zone_lookup is the only materialization build (from a .csv seed file):

![dbt](/Homework4/homework_q2.png)

> 

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

> 

## SQL Series

Alright, in module 1, you had sql refresher. so now let's build on top of that with some serious SQL.

These are not meant to be easy - but they'll boost your SQL and Analytics skills to the next level.
So, without any further do, let's get started...

You might want to add some new dimensions year (e.g.: 2019, 2020), quarter (1, 2, 3, 4), year_quarter (e.g.: 2019/Q1, 2019-Q2), and month (e.g.: 1, 2, ..., 12), extracted from pickup_datetime, to your fct_taxi_trips OR dim_taxi_trips.sql models to facilitate filtering your queries

## Q5: Taxi Quarterly Revenue Growth

1. Create a new model fct_taxi_trips_quarterly_revenue.sql
2. Compute the Quarterly Revenues for each year for based on total_amount
3. Compute the Quarterly YoY (Year-over-Year) revenue growth
- e.g.: In 2020/Q1, Green Taxi had -12.34% revenue growth compared to 2019/Q1
- e.g.: In 2020/Q4, Yellow Taxi had +34.56% revenue growth compared to 2019/Q4

Considering the YoY Growth in 2020, which were the yearly quarters with the best (or less worse) and worst results for green, and yellow.


