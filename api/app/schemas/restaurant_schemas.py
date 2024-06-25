from pydantic import BaseModel


class RestaurantRequest(BaseModel):
    style: str = None
    vegetarian: bool = None
    open_now: bool = None


class RestaurantCreate(BaseModel):
    name: str
    style: str
    address: str
    vegetarian: bool
    open_hour: str
    close_hour: str
