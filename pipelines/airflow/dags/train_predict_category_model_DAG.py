from datetime import datetime

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from register_best_model import pick_and_register_best_model
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

# Define the training task
train_model_task = PythonOperator(
    task_id="train_model_task", python_callable=train_model, dag=dag
)

# define the task that picks the best model from the MLFlow experiment and registers it
register_best_model_task = PythonOperator(
    task_id="pick_and_register_best_model", python_callable=pick_and_register_best_model
)

train_model_task >> register_best_model_task
