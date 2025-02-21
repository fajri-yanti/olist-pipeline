import os
import pandas as pd
import psycopg2
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime


def load_csv_to_postgres(file_path, table_name, schema='staging', create_schema=False):
    conn = psycopg2.connect(
        host='postgres_olist_db', 
        port=5432,
        database='olist',
        user='postgres',
        password='password'
    )
    cur = conn.cursor()

    if create_schema:
        cur.execute(f"CREATE SCHEMA IF NOT EXISTS {schema};")

    cur.execute(f"SET search_path TO {schema};")

    df = pd.read_csv(file_path)
    columns = ', '.join([f'"{col}" TEXT' for col in df.columns])
    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS {table_name} ({columns});
    """
    cur.execute(create_table_query)

    copy_query = f"COPY {table_name} FROM STDIN WITH CSV HEADER DELIMITER ','"
    with open(file_path, 'r') as f:
        cur.copy_expert(copy_query, f)

    conn.commit()
    cur.close()
    conn.close()

def load_all_csv():
    folder_path = '/opt/airflow/data'
    for filename in os.listdir(folder_path):
        if filename.endswith('.csv'):
            file_path = os.path.join(folder_path, filename)
            table_name = filename.replace('.csv', '').lower()
            load_csv_to_postgres(file_path, table_name)



