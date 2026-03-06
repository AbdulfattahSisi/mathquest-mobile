"""
Questions Router — /api/v1/questions
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.database import get_db
from app.models import Question, Subject, User
from app.schemas import QuestionOut, QuestionWithAnswer, GenerateQuestionsRequest, SubjectOut
from app.security import get_current_user
from app.services.ai_service import AIService

router = APIRouter()
ai = AIService()


@router.get("/subjects", response_model=List[SubjectOut])
async def get_subjects(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Subject))
    return result.scalars().all()


@router.get("/", response_model=List[QuestionOut])
async def get_questions(
    subject_slug: Optional[str] = Query(None),
    difficulty: Optional[int] = Query(None, ge=1, le=5),
    limit: int = Query(10, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    stmt = select(Question)
    if subject_slug:
        subj = await db.execute(select(Subject).where(Subject.slug == subject_slug))
        subj = subj.scalar_one_or_none()
        if not subj:
            raise HTTPException(404, "Matière introuvable")
        stmt = stmt.where(Question.subject_id == subj.id)
    if difficulty:
        stmt = stmt.where(Question.difficulty == difficulty)

    stmt = stmt.order_by(func.random()).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


@router.get("/{question_id}/answer", response_model=QuestionWithAnswer)
async def get_question_with_answer(
    question_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(select(Question).where(Question.id == question_id))
    q = result.scalar_one_or_none()
    if not q:
        raise HTTPException(404, "Question introuvable")
    return q


@router.post("/generate", response_model=List[QuestionWithAnswer])
async def generate_questions(
    body: GenerateQuestionsRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Generate new questions using AI (OpenAI GPT)."""
    subj = await db.execute(select(Subject).where(Subject.slug == body.subject_slug))
    subj = subj.scalar_one_or_none()
    if not subj:
        raise HTTPException(404, "Matière introuvable")

    questions = await ai.generate_questions(
        subject_name=subj.name,
        difficulty=body.difficulty,
        count=body.count,
    )
    # Save to DB
    db_questions = []
    for q in questions:
        obj = Question(
            subject_id=subj.id,
            text=q["text"],
            options=q["options"],
            correct_answer=q["correct_answer"],
            explanation=q.get("explanation"),
            difficulty=body.difficulty,
            generated_by_ai=True,
        )
        db.add(obj)
        db_questions.append(obj)

    await db.commit()
    for obj in db_questions:
        await db.refresh(obj)
    return db_questions
