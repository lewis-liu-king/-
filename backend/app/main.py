from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import aircrafts, components

app = FastAPI(
    title="航空部件生命周期管理系统",
    description="航空部件全生命周期管理 API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(aircrafts.router, prefix="/api")
app.include_router(components.router, prefix="/api")


@app.get("/")
def root():
    return {"message": "航空部件生命周期管理系统 API", "version": "1.0.0"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
