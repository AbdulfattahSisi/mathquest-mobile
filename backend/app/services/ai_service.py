"""
AI Service — Adaptive Learning, Question Generation & Analytics
Uses: scikit-learn for adaptive difficulty + OpenAI GPT for question generation
"""
from __future__ import annotations
import json
import logging
from typing import Any, Dict, List, Optional, TYPE_CHECKING

import numpy as np
from sklearn.linear_model import LogisticRegression

from app.config import settings

if TYPE_CHECKING:
    from app.models import User, UserProgress, Subject

logger = logging.getLogger(__name__)


class AIService:
    """Central AI/ML service for MathQuest."""

    # ─────────────────────────────────────────────────────────────────────────
    # 1.  ADAPTIVE DIFFICULTY
    # ─────────────────────────────────────────────────────────────────────────

    def predict_optimal_difficulty(
        self,
        skill_level: float,       # 0.0 – 1.0 (accuracy history)
        recent_accuracy: float,   # last session accuracy
        current_difficulty: int,  # 1 – 5
    ) -> int:
        """
        Uses a simple zone-of-proximal-development heuristic + Logistic
        Regression on historical data (when enough sessions exist).

        Target: keep accuracy in the 60–80 % range (optimal learning zone).
        """
        # Heuristic (always available, zero-shot)
        if recent_accuracy > 0.85 and current_difficulty < 5:
            return min(current_difficulty + 1, 5)
        if recent_accuracy < 0.45 and current_difficulty > 1:
            return max(current_difficulty - 1, 1)

        # Skill-based mapping
        if skill_level >= 0.8:
            return min(current_difficulty + 1, 5)
        if skill_level <= 0.3:
            return max(current_difficulty - 1, 1)

        return current_difficulty

    def train_difficulty_model(
        self,
        performance_history: List[Dict],
    ) -> Optional[LogisticRegression]:
        """
        Train a Logistic Regression on past sessions.
        Features: [skill, accuracy, difficulty]  →  Label: did_user_pass (acc ≥ 0.65)
        Only trains when we have ≥ 20 data points.
        """
        if len(performance_history) < 20:
            return None

        X, y = [], []
        for p in performance_history:
            X.append([p.get("skill", 0.5), p.get("accuracy", 0.5), p.get("difficulty", 2)])
            y.append(1 if p.get("accuracy", 0) >= 0.65 else 0)

        X = np.array(X, dtype=float)
        y = np.array(y)

        model = LogisticRegression(max_iter=300)
        model.fit(X, y)
        return model

    def get_recommended_difficulty_ml(
        self,
        model: LogisticRegression,
        skill: float,
        accuracy: float,
    ) -> int:
        """Find the highest difficulty where the model predicts pass probability ≥ 0.60."""
        best_diff = 1
        for diff in range(1, 6):
            prob = model.predict_proba([[skill, accuracy, diff]])[0][1]
            if prob >= 0.60:
                best_diff = diff
        return best_diff

    # ─────────────────────────────────────────────────────────────────────────
    # 2.  AI QUESTION GENERATION (OpenAI GPT-4o-mini)
    # ─────────────────────────────────────────────────────────────────────────

    async def generate_questions(
        self,
        subject_name: str,
        difficulty: int,
        count: int = 5,
    ) -> List[Dict]:
        """
        Generate MCQ questions using GPT.
        Returns a list of dicts matching the Question schema.
        Falls back to hard-coded examples when OpenAI key is missing.
        """
        if not settings.OPENAI_API_KEY or settings.OPENAI_API_KEY.startswith("sk-your"):
            logger.warning("OpenAI API key not set — using fallback questions")
            return self._fallback_questions(subject_name, difficulty, count)

        try:
            from openai import AsyncOpenAI
            client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)

            difficulty_labels = {1: "très facile", 2: "facile", 3: "moyen", 4: "difficile", 5: "très difficile"}
            level_str = difficulty_labels.get(difficulty, "moyen")

            prompt = f"""
Tu es un professeur expert en {subject_name}.
Génère exactement {count} questions QCM (choix multiples) de niveau {level_str} (niveau {difficulty}/5).

Format JSON STRICT (tableau) :
[
  {{
    "text": "Énoncé de la question",
    "options": [
      {{"label": "A", "value": "Réponse A"}},
      {{"label": "B", "value": "Réponse B"}},
      {{"label": "C", "value": "Réponse C"}},
      {{"label": "D", "value": "Réponse D"}}
    ],
    "correct_answer": "A",
    "explanation": "Explication courte de la bonne réponse"
  }}
]
Réponds UNIQUEMENT avec le JSON, sans texte supplémentaire.
"""
            response = await client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.7,
                max_tokens=2000,
            )
            raw = response.choices[0].message.content.strip()
            # Strip markdown code blocks if present
            if raw.startswith("```"):
                raw = raw.split("```")[1]
                if raw.startswith("json"):
                    raw = raw[4:]
            return json.loads(raw)

        except Exception as exc:
            logger.error("OpenAI generation failed: %s", exc)
            return self._fallback_questions(subject_name, difficulty, count)

    def _fallback_questions(self, subject: str, difficulty: int, count: int) -> List[Dict]:
        """Static fallback questions when OpenAI is unavailable."""
        bank = [
            {
                "text": f"[{subject} — Difficulté {difficulty}] Quelle est la dérivée de f(x) = x² ?",
                "options": [
                    {"label": "A", "value": "2x"},
                    {"label": "B", "value": "x"},
                    {"label": "C", "value": "2"},
                    {"label": "D", "value": "x²"},
                ],
                "correct_answer": "A",
                "explanation": "La dérivée de xⁿ est n·xⁿ⁻¹, donc (x²)' = 2x.",
            },
            {
                "text": f"[{subject} — Difficulté {difficulty}] Simplifier : 3x + 2x = ?",
                "options": [
                    {"label": "A", "value": "6x"},
                    {"label": "B", "value": "5x"},
                    {"label": "C", "value": "5x²"},
                    {"label": "D", "value": "x⁵"},
                ],
                "correct_answer": "B",
                "explanation": "On additionne les coefficients : 3 + 2 = 5 donc 5x.",
            },
        ]
        # Repeat to reach desired count
        result = []
        for i in range(count):
            result.append(bank[i % len(bank)])
        return result

    # ─────────────────────────────────────────────────────────────────────────
    # 3.  ANALYTICS & RECOMMENDATIONS
    # ─────────────────────────────────────────────────────────────────────────

    async def generate_analytics(self, user: "User", progress_rows: List) -> Any:
        """Generate personalised analytics for the profile page."""
        from app.schemas import AnalyticsOut

        strengths, weaknesses, recommended = [], [], []
        subject_stats: Dict[str, Dict] = {}

        for prog, subj in progress_rows:
            acc = (prog.correct_answers / prog.questions_answered * 100) if prog.questions_answered else 0
            subject_stats[subj.name] = {
                "accuracy": round(acc, 1),
                "answered": prog.questions_answered,
            }
            if acc >= 70:
                strengths.append(subj.name)
            else:
                weaknesses.append(subj.name)
                recommended.append(subj.name)

        # Rule-based improvement tips
        tips = []
        if not progress_rows:
            tips.append("Commencez votre premier duel pour générer des statistiques !")
        else:
            if weaknesses:
                tips.append(f"Concentrez-vous sur : {', '.join(weaknesses[:2])}")
            if user.streak_days < 3:
                tips.append("Jouez chaque jour pour maintenir votre streak et gagner des bonus !")
            if user.level < 5:
                tips.append("Complétez 10 questions par jour pour monter rapidement en niveau.")
            if strengths:
                tips.append(f"Bravo ! Vous excellez en {', '.join(strengths[:2])}. Tentez les duels en ligne !")

        # Weekly stats (mock — in production query duel_answers grouped by day)
        weekly_stats: Dict[str, Any] = {
            "total_sessions": sum(1 for _, _ in progress_rows),
            "accuracy_by_subject": {n: s["accuracy"] for n, s in subject_stats.items()},
        }

        return AnalyticsOut(
            strengths=strengths,
            weaknesses=weaknesses,
            recommended_subjects=recommended[:3],
            improvement_tips=tips[:4],
            weekly_stats=weekly_stats,
        )
