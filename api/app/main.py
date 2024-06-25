from fastapi import FastAPI
from app.routers import restaurant_router

app = FastAPI()

# Include routers
app.include_router(restaurant_router.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
