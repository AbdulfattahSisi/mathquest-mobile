"""
SQLAlchemy ORM Models
"""
import uuid
from datetime import date, datetime
from sqlalchemy import (
    Column, String, Integer, Boolean, Float, Text,
    ForeignKey, DateTime, Date, ARRAY, UniqueConstraint
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from app.database import Base


def gen_uuid():
    return str(uuid.uuid4())


class User(Base):
    __tablename__ = "users"

    id            = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    username      = Column(String(50), unique=True, nullable=False)
    email         = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    level         = Column(Integer, default=1)
    total_points  = Column(Integer, default=0)
    avatar_url    = Column(String(500), nullable=True)
    streak_days   = Column(Integer, default=0)
    last_streak   = Column(Date, nullable=True)
    created_at    = Column(DateTime(timezone=True), default=datetime.utcnow)
    last_login    = Column(DateTime(timezone=True), nullable=True)

    progress  = relationship("UserProgress", back_populates="user", cascade="all, delete")
    ai_profile = relationship("UserAIProfile", back_populates="user", uselist=False, cascade="all, delete")


class Subject(Base):
    __tablename__ = "subjects"

    id          = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    name        = Column(String(100), nullable=False)
    slug        = Column(String(50), unique=True, nullable=False)
    description = Column(Text, nullable=True)
    icon        = Column(String(100), nullable=True)
    color       = Column(String(20), nullable=True)

    questions = relationship("Question", back_populates="subject")


class Question(Base):
    __tablename__ = "questions"

    id              = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    subject_id      = Column(UUID(as_uuid=False), ForeignKey("subjects.id", ondelete="CASCADE"))
    text            = Column(Text, nullable=False)
    options         = Column(JSONB, nullable=False)   # [{"label":"A","value":"..."}]
    correct_answer  = Column(String(5), nullable=False)
    explanation     = Column(Text, nullable=True)
    difficulty      = Column(Integer, default=1)
    tags            = Column(ARRAY(Text), default=[])
    generated_by_ai = Column(Boolean, default=False)
    times_shown     = Column(Integer, default=0)
    times_correct   = Column(Integer, default=0)
    created_at      = Column(DateTime(timezone=True), default=datetime.utcnow)

    subject = relationship("Subject", back_populates="questions")


class UserProgress(Base):
    __tablename__ = "user_progress"
    __table_args__ = (UniqueConstraint("user_id", "subject_id"),)

    id                 = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    user_id            = Column(UUID(as_uuid=False), ForeignKey("users.id", ondelete="CASCADE"))
    subject_id         = Column(UUID(as_uuid=False), ForeignKey("subjects.id", ondelete="CASCADE"))
    progress_percent   = Column(Integer, default=0)
    questions_answered = Column(Integer, default=0)
    correct_answers    = Column(Integer, default=0)
    avg_difficulty     = Column(Float, default=1.0)
    last_played        = Column(DateTime(timezone=True), nullable=True)

    user    = relationship("User", back_populates="progress")
    subject = relationship("Subject")


class Duel(Base):
    __tablename__ = "duels"

    id              = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    player1_id      = Column(UUID(as_uuid=False), ForeignKey("users.id", ondelete="CASCADE"))
    player2_id      = Column(UUID(as_uuid=False), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    subject_id      = Column(UUID(as_uuid=False), ForeignKey("subjects.id"), nullable=True)
    status          = Column(String(20), default="waiting")
    mode            = Column(String(20), default="solo")
    player1_score   = Column(Integer, default=0)
    player2_score   = Column(Integer, default=0)
    winner_id       = Column(UUID(as_uuid=False), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    total_questions = Column(Integer, default=10)
    question_ids    = Column(ARRAY(Text), default=[])
    created_at      = Column(DateTime(timezone=True), default=datetime.utcnow)
    finished_at     = Column(DateTime(timezone=True), nullable=True)

    answers = relationship("DuelAnswer", back_populates="duel", cascade="all, delete")


class DuelAnswer(Base):
    __tablename__ = "duel_answers"

    id            = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    duel_id       = Column(UUID(as_uuid=False), ForeignKey("duels.id", ondelete="CASCADE"))
    user_id       = Column(UUID(as_uuid=False), ForeignKey("users.id", ondelete="CASCADE"))
    question_id   = Column(UUID(as_uuid=False), ForeignKey("questions.id"), nullable=True)
    answer_given  = Column(String(5), nullable=True)
    is_correct    = Column(Boolean, nullable=True)
    time_taken_ms = Column(Integer, nullable=True)
    answered_at   = Column(DateTime(timezone=True), default=datetime.utcnow)

    duel = relationship("Duel", back_populates="answers")


class UserAIProfile(Base):
    __tablename__ = "user_ai_profile"

    id                     = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    user_id                = Column(UUID(as_uuid=False), ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    skill_vector           = Column(JSONB, default={})
    recommended_difficulty = Column(JSONB, default={})
    performance_history    = Column(JSONB, default=[])
    predicted_score        = Column(Float, default=0.5)
    total_sessions         = Column(Integer, default=0)
    avg_accuracy           = Column(Float, default=0.0)
    last_updated           = Column(DateTime(timezone=True), default=datetime.utcnow)

    user = relationship("User", back_populates="ai_profile")
