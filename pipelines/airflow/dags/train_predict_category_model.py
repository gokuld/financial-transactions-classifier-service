import mlflow
import pandas as pd
import spacy
from airflow.models import Variable
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import make_pipeline


def train_model():
    # init
    mlflow_experiment_name = "predict-product-category-airflow-model-training"
    s3_bucket = Variable.get("s3_bucket")
    s3_key = Variable.get("s3_key")
    mlflow_tracking_uri = Variable.get("mlflow_tracking_uri")

    # Set up MLflow
    mlflow.set_tracking_uri(mlflow_tracking_uri)
    mlflow.set_experiment(mlflow_experiment_name)

    with mlflow.start_run():
        # Load the dataset from S3
        s3_path = f"s3://{s3_bucket}/{s3_key}"
        print(f"Loading dataset from {s3_path}")
        df = pd.read_parquet(s3_path, storage_options={"anon": False})

        # Load spaCy's English model
        try:
            nlp = spacy.load("en_core_web_sm")
        except OSError:
            spacy.cli.download("en_core_web_sm")
            nlp = spacy.load("en_core_web_sm")

        # Define a preprocessing function using spaCy
        def preprocess_text(text):
            doc = nlp(text)
            # Lemmatize and remove stop words and punctuation
            tokens = [
                token.lemma_
                for token in doc
                if not token.is_stop and not token.is_punct
            ]
            return " ".join(tokens)

        # Apply preprocessing
        df["cleaned_description"] = df["description"].apply(preprocess_text)

        # Split data into features and target variable
        X = df["cleaned_description"]
        y = df["category"]

        # Split data into training and test sets
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )

        # Create a pipeline with TF-IDF vectorizer and Naive Bayes classifier
        pipeline = make_pipeline(TfidfVectorizer(), MultinomialNB())

        # Train the model
        pipeline.fit(X_train, y_train)

        # Log the model
        mlflow.sklearn.log_model(pipeline, "model")

        # Make predictions
        y_train_pred = pipeline.predict(X_train)
        y_test_pred = pipeline.predict(X_test)

        # Evaluate the model
        train_accuracy = accuracy_score(y_train, y_train_pred)
        test_accuracy = accuracy_score(y_test, y_test_pred)
        # report = classification_report(y_test, y_pred)

        mlflow.log_metric("train_accuracy", train_accuracy)
        mlflow.log_metric("test_accuracy", test_accuracy)
