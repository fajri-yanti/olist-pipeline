import pandas as pd
from airflow.providers.postgres.hooks.postgres import PostgresHook

def extract_load(table_config, **kwargs):
    source_pg_hook = PostgresHook(postgres_conn_id='postgres_olist_db_conn')  
    target_pg_hook = PostgresHook(postgres_conn_id='postgres_olist_mart_conn')  

    source_conn = source_pg_hook.get_sqlalchemy_engine().connect()
    target_conn = target_pg_hook.get_sqlalchemy_engine().connect()

    query = f"SELECT * FROM {table_config['source_table']}"
    df = pd.read_sql(query, source_conn)

    df['md_extracted_at'] = pd.Timestamp.now()

    df.to_sql(
        name=table_config['target_table'],
        schema=table_config['target_schema'],
        con=target_conn,
        if_exists='replace', 
        index=False
    )

    source_conn.close()
    target_conn.close()
