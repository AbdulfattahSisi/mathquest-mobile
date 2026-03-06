"""
Duels Router — /api/v1/duels
"""
from datetime import datetime
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models import Duel, DuelAnswer, Question, User, UserProgress, UserAIProfile, Subject
from app.schemas import CreateDuelRequest, SubmitAnswerRequest, DuelOut, DuelResult
from app.security import get_current_user
from app.services.ai_service import AIService

router = APIRouter()
ai = AIService()

POINTS_PER_CORRECT = 100
POINTS_WIN_BONUS   = 200


@router.post("/", response_model=DuelOut, status_code=201)
async def create_duel(
    body: CreateDuelRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Adaptive difficulty from AI profile
    ai_profile = await db.execute(
        select(UserAIProfile).where(UserAIProfile.user_id == current_user.id)
    )
    ai_profile = ai_profile.scalar_one_or_none()

    # Fetch subject to get slug for AI
    subj_res = await db.execute(select(Subject).where(Subject.id == body.subject_id))
    subj = subj_res.scalar_one_or_none()
    if not subj:
        raise HTTPException(404, "Matière introuvable")

    difficulty = 2  # default
    if ai_profile:
        rec = ai_profile.recommended_difficulty or {}
        difficulty = rec.get(subj.slug, 2)

    # Pick random questions at adaptive difficulty
    q_result = await db.execute(
        select(Question)
        .where(Question.subject_id == body.subject_id)
        .where(Question.difficulty == difficulty)
        .limit(body.total_questions)
    )
    questions = q_result.scalars().all()

    # Fallback: any difficulty if not enough
    if len(questions) < body.total_questions:
        q_result = await db.execute(
            select(Question)
            .where(Question.subject_id == body.subject_id)
            .limit(body.total_questions)
        )
        questions = q_result.scalars().all()

    duel = Duel(
        player1_id=current_user.id,
        subject_id=body.subject_id,
        mode=body.mode,
        total_questions=min(body.total_questions, len(questions)),
        question_ids=[str(q.id) for q in questions],
        status="active",
    )
    db.add(duel)
    await db.commit()
    await db.refresh(duel)
    return duel


@router.get("/{duel_id}", response_model=DuelOut)
async def get_duel(
    duel_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(select(Duel).where(Duel.id == duel_id))
    duel = result.scalar_one_or_none()
    if not duel:
        raise HTTPException(404, "Duel introuvable")
    return duel


@router.post("/{duel_id}/answer", response_model=DuelResult)
async def submit_answer(
    duel_id: str,
    body: SubmitAnswerRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Load duel
    res = await db.execute(select(Duel).where(Duel.id == duel_id))
    duel = res.scalar_one_or_none()
    if not duel or duel.status != "active":
        raise HTTPException(400, "Duel non actif")

    # Load question + check answer
    q_res = await db.execute(select(Question).where(Question.id == body.question_id))
    question = q_res.scalar_one_or_none()
    if not question:
        raise HTTPException(404, "Question introuvable")

    is_correct = (question.correct_answer == body.answer_given)

    # Save answer
    ans = DuelAnswer(
        duel_id=duel_id,
        user_id=current_user.id,
        question_id=body.question_id,
        answer_given=body.answer_given,
        is_correct=is_correct,
        time_taken_ms=body.time_taken_ms,
    )
    db.add(ans)

    # Update duel score
    if is_correct:
        duel.player1_score += POINTS_PER_CORRECT
    question.times_shown += 1
    if is_correct:
        question.times_correct += 1

    # Check if duel is finished (all questions answered)
    answers_res = await db.execute(
        select(DuelAnswer).where(
            DuelAnswer.duel_id == duel_id,
            DuelAnswer.user_id == current_user.id,
        )
    )
    answered_count = len(answers_res.scalars().all()) + 1  # +1 for current

    points_earned = 0
    new_level = current_user.level

    if answered_count >= duel.total_questions:
        duel.status = "finished"
        duel.finished_at = datetime.utcnow()
        duel.winner_id = current_user.id if duel.player1_score >= duel.player2_score else duel.player2_id

        # Award points
        points_earned = duel.player1_score
        if duel.winner_id == current_user.id:
            points_earned += POINTS_WIN_BONUS

        current_user.total_points += points_earned
        # Level up every 1000 points
        current_user.level = max(1, current_user.total_points // 1000 + 1)
        new_level = current_user.level

        # Update AI profile
        await _update_ai_profile(current_user, duel, db)

        # Update progress
        await _update_user_progress(current_user, duel, db)

    await db.commit()

    total_answered = answered_count
    accuracy = (duel.player1_score / (total_answered * POINTS_PER_CORRECT) * 100) if total_answered else 0

    return DuelResult(
        duel_id=duel_id,
        your_score=duel.player1_score,
        opponent_score=duel.player2_score,
        winner=str(duel.winner_id) if duel.winner_id else None,
        points_earned=points_earned,
        new_level=new_level,
        accuracy_pct=round(accuracy, 1),
    )


async def _update_user_progress(user: User, duel: Duel, db: AsyncSession):
    if not duel.subject_id:
        return
    res = await db.execute(
        select(UserProgress).where(
            UserProgress.user_id == user.id,
            UserProgress.subject_id == duel.subject_id,
        )
    )
    prog = res.scalar_one_or_none()
    correct = duel.player1_score // POINTS_PER_CORRECT
    if prog is None:
        prog = UserProgress(
            user_id=user.id,
            subject_id=duel.subject_id,
            questions_answered=duel.total_questions,
            correct_answers=correct,
            last_played=datetime.utcnow(),
        )
        db.add(prog)
    else:
        prog.questions_answered += duel.total_questions
        prog.correct_answers    += correct
        prog.last_played         = datetime.utcnow()

    if prog.questions_answered > 0:
        pct = int((prog.correct_answers / prog.questions_answered) * 100)
        prog.progress_percent = min(pct, 100)


async def _update_ai_profile(user: User, duel: Duel, db: AsyncSession):
    res = await db.execute(
        select(UserAIProfile).where(UserAIProfile.user_id == user.id)
    )
    profile = res.scalar_one_or_none()
    if profile is None:
        return

    profile.total_sessions += 1
    accuracy = duel.player1_score / (duel.total_questions * POINTS_PER_CORRECT)

    # Update running average accuracy
    n = profile.total_sessions
    profile.avg_accuracy = ((profile.avg_accuracy * (n - 1)) + accuracy) / n

    # Update recommended difficulty per subject
    if duel.subject_id:
        subj_res = await db.execute(select(Subject).where(Subject.id == duel.subject_id))
        subj = subj_res.scalar_one_or_none()
        if subj:
            slug = subj.slug
            rec = dict(profile.recommended_difficulty or {})
            current_diff = rec.get(slug, 2)
            # If accuracy > 80% → increase difficulty; < 50% → decrease
            if accuracy > 0.8 and current_diff < 5:
                rec[slug] = current_diff + 1
            elif accuracy < 0.5 and current_diff > 1:
                rec[slug] = current_diff - 1
            profile.recommended_difficulty = rec

            # Skill vector
            sv = dict(profile.skill_vector or {})
            sv[slug] = round(min(1.0, accuracy), 3)
            profile.skill_vector = sv

    profile.last_updated = datetime.utcnow()
