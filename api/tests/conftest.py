import pytest
from fastapi.testclient import TestClient
from pymongo import MongoClient
from app.main import app
from app.config.db_config import get_database


@pytest.fixture(scope="module")
def test_app():
    """
    Fixture to create a TestClient instance for testing FastAPI endpoints.
    """
    client = TestClient(app)
    yield client


@pytest.fixture(scope="module")
def test_db():
    """
    Fixture to create and yield a test database instance.
    The database is cleaned up after the tests run.
    """
    MONGODB_URL = "mongodb://localhost:27017/"
    client = MongoClient(MONGODB_URL)
    test_db = client["test_restaurantdb"]

    # Override the get_database function to return the test database
    def override_get_database():
        return test_db

    app.dependency_overrides[get_database] = override_get_database

    yield test_db

    # Clean up the database after tests
    client.drop_database("test_restaurantdb")
