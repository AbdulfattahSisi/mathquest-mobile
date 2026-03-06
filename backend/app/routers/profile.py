"""
Profile Router — /api/v1/profile
"""
from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models import User, UserProgress, UserAIProfile, Subject
from app.schemas import UserOut, UserProgressOut, AIProfileOut, AnalyticsOut
from app.security import get_current_user
from app.services.ai_service import AIService

router = APIRouter()
ai = AIService()


@router.get("/", response_model=UserOut)
async def get_profile(current_user: User = Depends(get_current_user)):
    return current_user


@router.get("/progress", response_model=List[UserProgressOut])
async def get_progress(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(UserProgress, Subject)
        .join(Subject, UserProgress.subject_id == Subject.id)
        .where(UserProgress.user_id == current_user.id)
    )
    rows = result.all()
    return [
        UserProgressOut(
            subject_id=str(prog.subject_id),
            subject_name=subj.name,
            progress_percent=prog.progress_percent,
            questions_answered=prog.questions_answered,
            correct_answers=prog.correct_answers,
            avg_difficulty=prog.avg_difficulty,
            last_played=prog.last_played,
        )
        for prog, subj in rows
    ]


@router.get("/ai-profile", response_model=AIProfileOut)
async def get_ai_profile(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    res = await db.execute(
        select(UserAIProfile).where(UserAIProfile.user_id == current_user.id)
    )
    profile = res.scalar_one_or_none()
    if not profile:
        return AIProfileOut(
            skill_vector={}, recommended_difficulty={},
            predicted_score=0.5, avg_accuracy=0.0, total_sessions=0
        )
    return AIProfileOut(
        skill_vector=profile.skill_vector or {},
        recommended_difficulty=profile.recommended_difficulty or {},
        predicted_score=profile.predicted_score,
        avg_accuracy=profile.avg_accuracy,
        total_sessions=profile.total_sessions,
    )


@router.get("/analytics", response_model=AnalyticsOut)
async def get_analytics(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Progress per subject
    result = await db.execute(
        select(UserProgress, Subject)
        .join(Subject, UserProgress.subject_id == Subject.id)
        .where(UserProgress.user_id == current_user.id)
    )
    rows = result.all()

    strengths, weaknesses = [], []
    for prog, subj in rows:
        acc = (prog.correct_answers / prog.questions_answered * 100) if prog.questions_answered else 0
        if acc >= 70:
            strengths.append(subj.name)
        else:
            weaknesses.append(subj.name)

    # AI-powered tips
    analytics = await ai.generate_analytics(current_user, rows)
    return analytics
