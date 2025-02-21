FROM apache/airflow:2.7.0

# Install PostgreSQL ODBC driver (harus sebagai root)
USER root
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    odbc-postgresql \
    && rm -rf /var/lib/apt/lists/*

# Beralih ke airflow user untuk instal dbt-bigquery
USER airflow
RUN pip install --no-cache-dir dbt-bigquery

# Set working directory untuk dbt
WORKDIR /dbt_project

# Default command
CMD ["dbt", "run"]
