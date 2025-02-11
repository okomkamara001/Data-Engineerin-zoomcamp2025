## Question 1:


Question 1: What is count of recards for the 2024 Yellow Taxi Data?

2024-01:2,964,624 2024-02:3,007 2024-03: 3,582,289 2024-04: 3,514,289 2024-05: 3,723,833 2024-06:3,539.193

> Total:

- 20,332,093

## Question 2:

Write a query to count the distinct number of PULocations for the entire dateset on both the tables.

What is the estimated amount of data that  will be read when this query is executed on the External table and the Table.

```
SELECT COUNT(DISTINCT PULocationID)
FROM `charged-scholar-446408-g1.nytaxi.external_yellow_tripdata`;

SELECT COUNT(DISTINCT PULocationID)
FROM `charged-scholar-446408-g1.nytaxi.yellow_tripdata`;

```
- 0 MB for the External Table and 155.12 MB for the Materialized Table.

## Question 3:

Write a query to retrieve PULocationID from the table (not the external table) in BigQuery. Now wtite a query to retrieve the PULocationID and DOLocationID on the same table. Why are the estimated number of bytes different?

> BigQuery is a columnar database, and it only scans the specific columns requested in the query. Quering two columns (PULocationID,POLocationID) requires reading more data than quering one column (PULocation), leading to a higher estimated number of bytes processed.
    

## Question 4:

How many records fare_amount of 0?

Total

- 8,333


## Question 5:
What is the best strategy to make an optimized table in Big Query if your query will always filtered based on tpep_dropoff_datetime and order the results by VendorID (create a new table with this strategy)

```
CREATE OR REPLACE TABLE charged-scholar-446408-g1.nytaxi.yellow_tripdata_partitoned_clustered
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM charged-scholar-446408-g1.nytaxi.external_yellow_tripdata;

```

- Partition by  by tpep_dropoff_datetime and Cluster on VendorID

## Question 6:
Write a query to retrieve the distants VendorIDs between tpep_dropoff_datetime 2024-03-01 and 2024-03-15 (inclusive).

Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 5 and notes the estimated bytes processed. what are these values?

Choose the answer which most closely matched.

```
SELECT DISTINCT VendorID

FROM 
  charged-scholar-446408-g1.nytaxi.yellow_tripdata

WHERE
  tpep_dropoff_datetime > '2024-03-01' AND
  tpep_dropoff_datetime <= '2024-03-15';

```

```
SELECT DISTINCT VendorID

FROM 
  charged-scholar-446408-g1.nytaxi.yellow_tripdata_partitoned

WHERE
  tpep_dropoff_datetime > '2024-03-01' AND
  tpep_dropoff_datetime <= '2024-03-15';

```

- 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table.


## Question 7: 
Where is the data for external tables stored?

- GCP Bucket

## Question 8:
Always clustering

- False


## (Bonus: Not worth points) Question 9:

No Points: Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read.

Why?

- O MB estimated to read. BigQuery stores the metadata of the table,hence it already has the result of the number of rows of the table and doesn't require to scan the table again