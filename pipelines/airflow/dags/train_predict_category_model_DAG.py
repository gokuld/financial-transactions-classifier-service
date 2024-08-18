from datetime import datetime

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from train_predict_category_model import train_model

# Define the default arguments
default_args = {"owner": "airflow", "start_date": datetime(2024, 8, 1), "retries": 1}

# Define the DAG
dag = DAG(
    "predict_category_model_training_dag",
    default_args=default_args,
    schedule_interval="@once",  # No schedule, runs only once
    catchup=False,
)

# Define the task
train_model_task = PythonOperator(
    task_id="train_model_task", python_callable=train_model, dag=dag
)

train_model_task
