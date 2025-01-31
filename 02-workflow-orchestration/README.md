## 
  pgdatabase:
      image: postgres
      container_name: postgres-db
      environment:
        POSTGRES_USER: kestra
        POSTGRES_PASSWORD: k3str4
        POSTGRES_DB: postgres-zoomcamp
      ports:
        - "5432:5432"
      volumes:
        - postgres-data2:/var/lib/postgresql/data

  pgadmin:
      image: dpage/pgadmin4
      environment:
        - PGADMIN_DEFAULT_EMAIL=admin@admin.com
        - PGADMIN_DEFAULT_PASSWORD=root
      ports:
        - "8090:80"