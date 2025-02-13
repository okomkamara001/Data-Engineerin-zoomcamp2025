import dlt

pipeline = dlt.pipeline(pipeline_name="my_pipeline", destination="postgres", dataset_name="my_data")

data = [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}]

# Load the data into PostgreSQL
info = pipeline.run(data, table_name="users")
print(info)