from fastapi import APIRouter
api_router = APIRouter()
@api_router.get("/hello")
def hello_world():
    return {"message": "Hello from FastAPI (Next.js Edition)"}
