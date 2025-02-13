
## Workshop "Data Ingestion with dlt": HomeWork

<hr style="border: 3px solid;">

## Dataset & API

We'll use NYC Taxi data via the same custom API from the workshop

- Base API URL

> https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api

- Data format: Paginated JSON(1,000 records per page).
- API Pagination: Stop when an empty page is returned

## Question 1: dlt Version

1. Install dlt:

> pip install dlt[duckdb]

- dlt 1.6.1



## Question 2: Define & Run the pipeline (NTC TaxI API)

  > How many tables were created?
  - 4

## Explore the loaded data
> df = pipeline.dataset(dataset_type="default").rides.df()
df
## Question 3: What is the total number of record extracted?
- 10,000

## Trip Duration Analysis
## Question 4: Calculate the average trip duration in minutes.

- 12.3049
