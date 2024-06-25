import pytest
from app.schemas.restaurant_schemas import RestaurantCreate, RestaurantRequest


@pytest.fixture
def new_restaurant():
    """
    Fixture to create a new restaurant object for testing.
    """
    return {
        "name": "Test Restaurant",
        "style": "Test Style",
        "address": "Test Address",
        "vegetarian": True,
        "open_hour": "10:00",
        "close_hour": "22:00"
    }


@pytest.fixture
def restaurant_request():
    """
    Fixture to create a restaurant request object for testing recommendations.
    """
    return {
        "style": "Test Style",
        "vegetarian": True,
        "open_now": True
    }


def test_add_restaurant(test_app, test_db, new_restaurant):
    """
    Test case for adding a new restaurant.
    """
    response = test_app.post("/restaurants", json=new_restaurant)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == new_restaurant["name"]
    assert data["style"] == new_restaurant["style"]


def test_add_restaurant_invalid_data(test_app):
    """
    Test case for adding a new restaurant with invalid data.
    """
    invalid_restaurant = {
        "name": "Invalid Restaurant",
        "style": "Invalid Style",
        "address": "Invalid Address",
        "vegetarian": "Yes",  # Should be a boolean
        "open_hour": "10:00",
        "close_hour": "22:00"
    }
    response = test_app.post("/restaurants", json=invalid_restaurant)
    assert response.status_code == 422


def test_get_recommendation(test_app, test_db, new_restaurant, restaurant_request):
    """
    Test case for getting a restaurant recommendation.
    """
    # First, add a restaurant to the database
    test_app.post("/restaurants", json=new_restaurant)

    # Then, check for a restaurant recommendation
    response = test_app.post("/recommendation", json=restaurant_request)
    assert response.status_code == 200
    data = response.json()["restaurantRecommendation"]
    assert data["name"] == new_restaurant["name"]
    assert data["style"] == new_restaurant["style"]


def test_get_recommendation_no_match(test_app):
    """
    Test case for getting a restaurant recommendation with no matching restaurant.
    """
    request = {
        "style": "Nonexistent Style",
        "vegetarian": False,
        "open_now": True
    }
    response = test_app.post("/recommendation", json=request)
    assert response.status_code == 404
    assert response.json()["detail"] == "No matching restaurant found"


def test_get_recommendation_invalid_data(test_app):
    """
    Test case for getting a restaurant recommendation with invalid data.
    """
    invalid_request = {
        "style": "Test Style",
        "vegetarian": "Yes",  # Should be a boolean
        "open_now": True
    }
    response = test_app.post("/recommendation", json=invalid_request)
    assert response.status_code == 422
