import pytest
from datetime import time, datetime
from app.crud.restaurants_crud import create_restaurant, get_recommended_restaurant
from app.schemas.restaurant_schemas import RestaurantCreate, RestaurantRequest


@pytest.fixture
def new_restaurant():
    """
    Fixture to create a new RestaurantCreate object for testing.
    """
    return RestaurantCreate(
        name="Test Restaurant",
        style="Test Style",
        address="Test Address",
        vegetarian=True,
        open_hour="10:00",
        close_hour="22:00"
    )


@pytest.fixture
def restaurant_request():
    """
    Fixture to create a RestaurantRequest object for testing recommendations.
    """
    return RestaurantRequest(
        style="Test Style",
        vegetarian=True,
        open_now=True
    )


def test_create_restaurant(test_db, new_restaurant):
    """
    Test case for creating a new restaurant in the database.
    """
    collection = test_db.get_collection("restaurants")
    created_restaurant = create_restaurant(collection, new_restaurant)
    assert created_restaurant["name"] == new_restaurant.name
    assert created_restaurant["style"] == new_restaurant.style


def test_create_restaurant_duplicate(test_db, new_restaurant):
    """
    Test case for creating a duplicate restaurant in the database.
    """
    collection = test_db.get_collection("restaurants")
    create_restaurant(collection, new_restaurant)
    with pytest.raises(Exception):
        create_restaurant(collection, new_restaurant)


def test_get_recommended_restaurant(test_db, new_restaurant, restaurant_request):
    """
    Test case for getting a recommended restaurant from the database.
    """
    collection = test_db.get_collection("restaurants")
    create_restaurant(collection, new_restaurant)

    recommended_restaurant = get_recommended_restaurant(collection, restaurant_request)
    assert recommended_restaurant["name"] == new_restaurant.name
    assert recommended_restaurant["style"] == new_restaurant.style


def test_get_recommended_restaurant_no_match(test_db, restaurant_request):
    """
    Test case for getting a recommended restaurant with no matching restaurant in the database.
    """
    collection = test_db.get_collection("restaurants")
    recommended_restaurant = get_recommended_restaurant(collection, restaurant_request)
    assert recommended_restaurant is None


def test_get_recommended_restaurant_invalid_time(test_db, new_restaurant):
    """
    Test case for getting a recommended restaurant with invalid time.
    """
    collection = test_db.get_collection("restaurants")
    create_restaurant(collection, new_restaurant)

    request = RestaurantRequest(
        style="Test Style",
        vegetarian=True,
        open_now=True
    )

    # Manually change the current time to be outside of the open hours
    request.open_now = True
    request.current_time = "23:00"  # Restaurant closes at 22:00

    recommended_restaurant = get_recommended_restaurant(collection, request)
    assert recommended_restaurant is None
