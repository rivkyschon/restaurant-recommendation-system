from datetime import datetime


def get_recommended_restaurant(collection, request):
    """
    Fetches a recommended restaurant based on the given request criteria.

    :param collection: MongoDB's collection of restaurants.
    :param request: Request object containing search criteria.
    :return: Recommended restaurant or None if no match found.
    """
    query = {}
    if request.style:
        query["style"] = request.style
    if request.vegetarian is not None:
        query["vegetarian"] = request.vegetarian
    if request.open_now:
        current_time = str(datetime.now().time())
        query["open_hour"] = {"$lte": current_time}
        query["close_hour"] = {"$gte": current_time}

    return collection.find_one(query)


def create_restaurant(collection, restaurant):
    """
    Creates a new restaurant entry in the database.

    :param collection: MongoDB's collection of restaurants.
    :param restaurant: Restaurant object containing restaurant details.
    :return: Created restaurant without the MongoDB ID field.
    """
    new_restaurant = {
        "name": restaurant.name,
        "style": restaurant.style,
        "address": restaurant.address,
        "vegetarian": restaurant.vegetarian,
        "open_hour": restaurant.open_hour,
        "close_hour": restaurant.close_hour
    }
    result = collection.insert_one(new_restaurant)
    return collection.find_one({"_id": result.inserted_id}, {'_id': 0})
