import pandas as pd
import psycopg2


def extract_load(file_path, table_name, schema='raw_data'):
    conn = psycopg2.connect(
        host='postgres_olist_db',
        port=5432,
        database='olist_db',
        user='postgres',
        password='password'
    )
    cur = conn.cursor()

    cur.execute(f"CREATE SCHEMA IF NOT EXISTS {schema};")

    cur.execute(f"SET search_path TO {schema};")

    df = pd.read_csv(file_path)

    columns = ', '.join([f'"{col}" TEXT' for col in df.columns])
    create_table_query = f"CREATE TABLE IF NOT EXISTS {table_name} ({columns});"
    cur.execute(create_table_query)

    copy_query = f"COPY {table_name} FROM STDIN WITH CSV HEADER DELIMITER ','"
    with open(file_path, 'r') as f:
        cur.copy_expert(copy_query, f)

    conn.commit()
    cur.close()
    conn.close()
