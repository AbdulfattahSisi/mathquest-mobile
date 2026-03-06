-- ============================================================
-- MathQuest Mobile - PostgreSQL Database Schema
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ──────────────────────────────────────────
-- USERS
-- ──────────────────────────────────────────
CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username      VARCHAR(50)  UNIQUE NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    level         INTEGER DEFAULT 1,
    total_points  INTEGER DEFAULT 0,
    avatar_url    VARCHAR(500),
    streak_days   INTEGER DEFAULT 0,
    last_streak   DATE,
    created_at    TIMESTAMPTZ DEFAULT NOW(),
    last_login    TIMESTAMPTZ
);

-- ──────────────────────────────────────────
-- SUBJECTS
-- ──────────────────────────────────────────
CREATE TABLE subjects (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100) NOT NULL,
    slug        VARCHAR(50)  UNIQUE NOT NULL,
    description TEXT,
    icon        VARCHAR(100),
    color       VARCHAR(20)
);

-- ──────────────────────────────────────────
-- QUESTIONS
-- ──────────────────────────────────────────
CREATE TABLE questions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id      UUID REFERENCES subjects(id) ON DELETE CASCADE,
    text            TEXT NOT NULL,
    options         JSONB NOT NULL,  -- [{"label":"A","value":"6x+2"}, ...]
    correct_answer  VARCHAR(5) NOT NULL,  -- "A", "B", "C", or "D"
    explanation     TEXT,
    difficulty      INTEGER DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
    tags            TEXT[] DEFAULT '{}',
    generated_by_ai BOOLEAN DEFAULT FALSE,
    times_shown     INTEGER DEFAULT 0,
    times_correct   INTEGER DEFAULT 0,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- USER PROGRESS (per subject)
-- ──────────────────────────────────────────
CREATE TABLE user_progress (
    id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id            UUID REFERENCES users(id) ON DELETE CASCADE,
    subject_id         UUID REFERENCES subjects(id) ON DELETE CASCADE,
    progress_percent   INTEGER DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    questions_answered INTEGER DEFAULT 0,
    correct_answers    INTEGER DEFAULT 0,
    avg_difficulty     FLOAT DEFAULT 1.0,
    last_played        TIMESTAMPTZ,
    UNIQUE(user_id, subject_id)
);

-- ──────────────────────────────────────────
-- DUELS
-- ──────────────────────────────────────────
CREATE TABLE duels (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player1_id       UUID REFERENCES users(id) ON DELETE CASCADE,
    player2_id       UUID REFERENCES users(id) ON DELETE SET NULL,
    subject_id       UUID REFERENCES subjects(id),
    status           VARCHAR(20) DEFAULT 'waiting'
                        CHECK (status IN ('waiting','active','finished','cancelled')),
    mode             VARCHAR(20) DEFAULT 'solo'
                        CHECK (mode IN ('solo','online','tournament')),
    player1_score    INTEGER DEFAULT 0,
    player2_score    INTEGER DEFAULT 0,
    winner_id        UUID REFERENCES users(id) ON DELETE SET NULL,
    total_questions  INTEGER DEFAULT 10,
    question_ids     UUID[] DEFAULT '{}',
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    finished_at      TIMESTAMPTZ
);

-- ──────────────────────────────────────────
-- DUEL ANSWERS
-- ──────────────────────────────────────────
CREATE TABLE duel_answers (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    duel_id       UUID REFERENCES duels(id) ON DELETE CASCADE,
    user_id       UUID REFERENCES users(id) ON DELETE CASCADE,
    question_id   UUID REFERENCES questions(id),
    answer_given  VARCHAR(5),
    is_correct    BOOLEAN,
    time_taken_ms INTEGER,
    answered_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- BADGES
-- ──────────────────────────────────────────
CREATE TABLE badges (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name             VARCHAR(100) NOT NULL,
    description      TEXT,
    icon             VARCHAR(100),
    condition_type   VARCHAR(50),   -- 'duels_won' | 'level_reached' | 'streak_days' | 'accuracy'
    condition_value  INTEGER
);

CREATE TABLE user_badges (
    user_id    UUID REFERENCES users(id) ON DELETE CASCADE,
    badge_id   UUID REFERENCES badges(id) ON DELETE CASCADE,
    earned_at  TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, badge_id)
);

-- ──────────────────────────────────────────
-- AI ADAPTIVE PROFILE
-- ──────────────────────────────────────────
CREATE TABLE user_ai_profile (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id                 UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    skill_vector            JSONB DEFAULT '{}',        -- {subject_slug: 0.0-1.0}
    recommended_difficulty  JSONB DEFAULT '{}',        -- {subject_slug: 1-5}
    performance_history     JSONB DEFAULT '[]',        -- last 50 session results
    predicted_score         FLOAT DEFAULT 0.5,
    total_sessions          INTEGER DEFAULT 0,
    avg_accuracy            FLOAT DEFAULT 0.0,
    last_updated            TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- NOTIFICATIONS (Node.js analytics service)
-- ──────────────────────────────────────────
CREATE TABLE notifications (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
    title       VARCHAR(200) NOT NULL,
    message     TEXT NOT NULL,
    type        VARCHAR(30) DEFAULT 'info'
                    CHECK (type IN ('info','achievement','streak','announcement','warning')),
    is_read     BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- ANALYTICS EVENTS (Node.js analytics service)
-- ──────────────────────────────────────────
CREATE TABLE analytics_events (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type  VARCHAR(50) NOT NULL,
    user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
    payload     JSONB DEFAULT '{}',
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- INDEXES
-- ──────────────────────────────────────────
CREATE INDEX idx_questions_subject    ON questions(subject_id);
CREATE INDEX idx_questions_difficulty ON questions(difficulty);
CREATE INDEX idx_user_progress_user   ON user_progress(user_id);
CREATE INDEX idx_duels_player1        ON duels(player1_id);
CREATE INDEX idx_duels_status         ON duels(status);
CREATE INDEX idx_duel_answers_duel    ON duel_answers(duel_id);
CREATE INDEX idx_duel_answers_user    ON duel_answers(user_id);
CREATE INDEX idx_notifications_user   ON notifications(user_id);
CREATE INDEX idx_analytics_events_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_events_user ON analytics_events(user_id);
