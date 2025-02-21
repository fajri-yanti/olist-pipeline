import pytz
import yaml
from datetime import datetime
from airflow.decorators import dag
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
import os
from csv_to_postgre import load_csv_to_postgres

with open("/opt/airflow/dags/resources/config/olist.yml", "r") as f:
    config = yaml.safe_load(f)


@dag(
    schedule_interval="@daily",
    start_date=datetime(2024, 2, 1, tzinfo=pytz.timezone("Asia/Jakarta")),
    catchup=False,
    tags=["elt_olist"],
)
def dag_elt_olist():
    start_task = EmptyOperator(task_id="start_task")
    end_task = EmptyOperator(task_id="end_task")
    wait_el_task = EmptyOperator(task_id="wait_el_task")
    wait_transform_task = EmptyOperator(task_id="wait_transform_task")

    el_tasks = []

    for table_name, table_config in config["ingestion"].items():
        el_task = PythonOperator(
            task_id=f"extract_load_{table_name}",
            python_callable=load_csv_to_postgres,
            op_kwargs={
                "file_path": f"/opt/airflow/data/{table_config['source']}",
                "table_name": table_name,
                "schema": "raw_data",
            },
        )
        el_tasks.append(el_task)
        start_task >> el_task >> wait_el_task

    transform_tasks = []

    for filepath in config.get("transform", []):
        file_name = os.path.basename(filepath).replace('.sql', '')
        transform_task = SQLExecuteQueryOperator(
            task_id=f"transform_{file_name}",
            conn_id="postgres_olist_db_conn",
            sql=filepath,
        )
        transform_tasks.append(transform_task)
        wait_el_task >> transform_task >> wait_transform_task

    wait_transform_task >> end_task


dag_elt_olist()
