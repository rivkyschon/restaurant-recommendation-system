from fastapi import APIRouter, HTTPException
from app.schemas.restaurant_schemas import RestaurantRequest, RestaurantCreate
from app.config.db_config import get_database, get_restaurant_collection
from app.crud.restaurants_crud import get_recommended_restaurant, create_restaurant

router = APIRouter()


@router.post("/recommendation")
def get_recommendation(request: RestaurantRequest):
    db = get_database()
    collection = get_restaurant_collection(db)
    restaurant = get_recommended_restaurant(collection, request)
    if not restaurant:
        raise HTTPException(status_code=404, detail="No matching restaurant found")

    return {
        "restaurantRecommendation": {
            "name": restaurant["name"],
            "style": restaurant["style"],
            "address": restaurant["address"],
            "openHour": str(restaurant["open_hour"]),
            "closeHour": str(restaurant["close_hour"]),
            "vegetarian": restaurant["vegetarian"]
        }
    }


@router.post("/restaurants")
def add_restaurant(restaurant: RestaurantCreate):
    db = get_database()
    collection = get_restaurant_collection(db)
    created_restaurant = create_restaurant(collection, restaurant)
    return created_restaurant


@router.get("/health")
def health_check():
    return {"status": "ok"}