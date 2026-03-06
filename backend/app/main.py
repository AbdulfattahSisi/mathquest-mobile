"""
MathQuest FastAPI Backend — Entry Point
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.database import engine, Base
from app.routers import auth, questions, duels, leaderboard, profile
from app.config import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: create tables if they don't exist
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Shutdown
    await engine.dispose()


app = FastAPI(
    title="MathQuest API",
    description="Backend REST API pour MathQuest Mobile",
    version="1.0.0",
    lifespan=lifespan,
)

# ── CORS ──────────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(auth.router,        prefix="/api/v1/auth",        tags=["Auth"])
app.include_router(questions.router,   prefix="/api/v1/questions",   tags=["Questions"])
app.include_router(duels.router,       prefix="/api/v1/duels",       tags=["Duels"])
app.include_router(leaderboard.router, prefix="/api/v1/leaderboard", tags=["Leaderboard"])
app.include_router(profile.router,     prefix="/api/v1/profile",     tags=["Profile"])


@app.get("/", tags=["Health"])
async def root():
    return {"status": "ok", "message": "MathQuest API v1.0.0"}
