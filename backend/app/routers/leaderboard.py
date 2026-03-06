"""
Leaderboard Router — /api/v1/leaderboard
"""
from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models import User
from app.schemas import LeaderboardEntry
from app.security import get_current_user

router = APIRouter()


@router.get("/", response_model=List[LeaderboardEntry])
async def get_leaderboard(
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(User)
        .order_by(User.total_points.desc())
        .limit(limit)
    )
    users = result.scalars().all()

    return [
        LeaderboardEntry(
            rank=idx + 1,
            user_id=str(u.id),
            username=u.username,
            total_points=u.total_points,
            level=u.level,
            avatar_url=u.avatar_url,
        )
        for idx, u in enumerate(users)
    ]
