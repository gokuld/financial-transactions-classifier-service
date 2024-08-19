import mlflow
from airflow.models import Variable
from mlflow.tracking import MlflowClient


def pick_and_register_best_model():
    mlflow_experiment_name = "predict-product-category-airflow-model-training"
    mlflow_tracking_uri = Variable.get("mlflow_tracking_uri")
    registered_model_name = "predict-product-category"

    # Set MLflow tracking URI
    mlflow.set_tracking_uri(mlflow_tracking_uri)

    # Get the experiment ID
    experiment = mlflow.get_experiment_by_name(mlflow_experiment_name)
    if experiment is None:
        raise ValueError(f"Experiment with name '{mlflow_experiment_name}' not found")
    experiment_id = experiment.experiment_id

    # Initialize MLflow client
    client = MlflowClient(tracking_uri=mlflow_tracking_uri)

    # Get all runs in the experiment
    runs = client.search_runs(
        experiment_ids=experiment_id,
        filter_string="",
        order_by=["metrics.test_accuracy DESC"],
    )

    if not runs:
        raise ValueError("No runs found in the experiment")

    # Get the best run (highest test_accuracy)
    best_run = runs[0]

    # Register the model from the best run
    model_uri = f"runs:/{best_run.info.run_id}/model"
    client.create_registered_model(registered_model_name)
    client.create_model_version(registered_model_name, model_uri, best_run.info.run_id)

    print(
        f"Registered model version from run {best_run.info.run_id}\
 with test_accuracy {best_run.data.metrics['test_accuracy']}"
    )
