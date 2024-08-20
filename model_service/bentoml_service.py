import bentoml
import mlflow
import spacy
from config import MLFLOW_TRACKING_URI


@bentoml.service(
    resources={"cpu": "1", "memory": "512Mi"},
    traffic={"timeout": 10},
)
class PredictProductCategory:
    def __init__(self):
        # Set MLflow tracking URI
        mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)

        # Load spaCy's English model
        try:
            self.nlp = spacy.load("en_core_web_sm")
        except OSError:
            spacy.cli.download("en_core_web_sm")
            self.nlp = spacy.load("en_core_web_sm")

        self.model_name = "predict-product-category"
        self.model_uri = f"models:/{self.model_name}/latest"

    # Define the preprocessing function using spaCy
    def preprocess_text(self, text):
        doc = self.nlp(text)
        # Lemmatize and remove stop words and punctuation
        tokens = [
            token.lemma_ for token in doc if not token.is_stop and not token.is_punct
        ]
        return " ".join(tokens)

    @bentoml.api
    def predict(self, text: str) -> str:
        try:
            bentoml.mlflow.import_model(self.model_name, self.model_uri)
            self.model = bentoml.mlflow.load_model(f"{self.model_name}:latest")
            category_prediction = self.model.predict([self.preprocess_text(text)])[0]
        except Exception:
            category_prediction = "None"

        return category_prediction
