from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()
MONGODB_URL = os.getenv("MONGODB_URL")
client = MongoClient(MONGODB_URL)


def get_database():
    """
    Returns a connection to the MongoDB database.
    """
    return client.get_database("RestaurantsFinder")


def get_restaurant_collection(db):
    """
    Returns the restaurant collection from the database.
    """
    return db.get_collection("restaurants")
