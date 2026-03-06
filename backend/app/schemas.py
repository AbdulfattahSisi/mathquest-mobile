"""
Pydantic Schemas (request / response models)
"""
from __future__ import annotations
from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, EmailStr, field_validator


# ── Auth ──────────────────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    username: str
    email: EmailStr
    password: str

class LoginRequest(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserOut(BaseModel):
    id: str
    username: str
    email: str
    level: int
    total_points: int
    avatar_url: Optional[str]
    streak_days: int
    created_at: datetime

    class Config:
        from_attributes = True


# ── Subject ───────────────────────────────────────────────────────────────────

class SubjectOut(BaseModel):
    id: str
    name: str
    slug: str
    description: Optional[str]
    icon: Optional[str]
    color: Optional[str]

    class Config:
        from_attributes = True


# ── Questions ─────────────────────────────────────────────────────────────────

class QuestionOption(BaseModel):
    label: str   # "A", "B", "C", "D"
    value: str   # answer text

class QuestionOut(BaseModel):
    id: str
    subject_id: str
    text: str
    options: List[QuestionOption]
    difficulty: int
    tags: List[str]
    generated_by_ai: bool

    class Config:
        from_attributes = True

class QuestionWithAnswer(QuestionOut):
    correct_answer: str
    explanation: Optional[str]

class GenerateQuestionsRequest(BaseModel):
    subject_slug: str
    difficulty: int = 2
    count: int = 5


# ── User Progress ─────────────────────────────────────────────────────────────

class UserProgressOut(BaseModel):
    subject_id: str
    subject_name: str
    progress_percent: int
    questions_answered: int
    correct_answers: int
    avg_difficulty: float
    last_played: Optional[datetime]

    class Config:
        from_attributes = True


# ── Duels ─────────────────────────────────────────────────────────────────────

class CreateDuelRequest(BaseModel):
    subject_id: str
    mode: str = "solo"          # "solo" | "online" | "tournament"
    total_questions: int = 10

class SubmitAnswerRequest(BaseModel):
    question_id: str
    answer_given: str
    time_taken_ms: int

class DuelOut(BaseModel):
    id: str
    subject_id: Optional[str]
    mode: str
    status: str
    player1_score: int
    player2_score: int
    total_questions: int
    created_at: datetime

    class Config:
        from_attributes = True

class DuelResult(BaseModel):
    duel_id: str
    your_score: int
    opponent_score: int
    winner: Optional[str]
    points_earned: int
    new_level: int
    accuracy_pct: float


# ── Leaderboard ───────────────────────────────────────────────────────────────

class LeaderboardEntry(BaseModel):
    rank: int
    user_id: str
    username: str
    total_points: int
    level: int
    avatar_url: Optional[str]


# ── AI ────────────────────────────────────────────────────────────────────────

class AIProfileOut(BaseModel):
    skill_vector: Dict[str, float]
    recommended_difficulty: Dict[str, int]
    predicted_score: float
    avg_accuracy: float
    total_sessions: int

class AnalyticsOut(BaseModel):
    strengths: List[str]
    weaknesses: List[str]
    recommended_subjects: List[str]
    improvement_tips: List[str]
    weekly_stats: Dict[str, Any]
