FROM apache/airflow:2.7.0

USER root
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    odbc-postgresql \
    && rm -rf /var/lib/apt/lists/*

USER airflow
RUN pip install --no-cache-dir dbt-bigquery

WORKDIR /dbt_project
CMD ["dbt", "run"]
