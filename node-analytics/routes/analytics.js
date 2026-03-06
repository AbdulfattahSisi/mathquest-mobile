/**
 * Analytics Routes — DAU, retention, performance metrics
 * GET /api/analytics/overview      → global stats
 * GET /api/analytics/daily         → daily active users & games
 * GET /api/analytics/performance   → per-subject accuracy distribution
 * GET /api/analytics/retention     → 7-day retention data
 */

const express = require('express');
const router = express.Router();
const db = require('../db');

// ── Global Overview ─────────────────────────────────────────────────────────
router.get('/overview', async (_req, res) => {
  try {
    const [users, duels, questions] = await Promise.all([
      db.query('SELECT COUNT(*) AS count FROM users'),
      db.query('SELECT COUNT(*) AS count FROM duels WHERE status = $1', ['finished']),
      db.query('SELECT COUNT(*) AS count FROM questions'),
    ]);

    const avgScore = await db.query(
      `SELECT COALESCE(AVG(player1_score), 0) AS avg_score
       FROM duels WHERE status = 'finished'`
    );

    res.json({
      totalUsers: parseInt(users.rows[0].count),
      totalDuels: parseInt(duels.rows[0].count),
      totalQuestions: parseInt(questions.rows[0].count),
      averageScore: parseFloat(avgScore.rows[0].avg_score).toFixed(1),
      generatedAt: new Date().toISOString(),
    });
  } catch (err) {
    console.error('Analytics overview error:', err.message);
    res.status(500).json({ error: 'Failed to fetch analytics' });
  }
});

// ── Daily Active Users (last 30 days) ───────────────────────────────────────
router.get('/daily', async (_req, res) => {
  try {
    const result = await db.query(`
      SELECT
        DATE(created_at) AS day,
        COUNT(DISTINCT player1_id) AS active_users,
        COUNT(*) AS total_games
      FROM duels
      WHERE created_at >= NOW() - INTERVAL '30 days'
      GROUP BY DATE(created_at)
      ORDER BY day DESC
    `);

    res.json({
      period: '30d',
      data: result.rows.map((r) => ({
        date: r.day,
        activeUsers: parseInt(r.active_users),
        totalGames: parseInt(r.total_games),
      })),
    });
  } catch (err) {
    console.error('Daily analytics error:', err.message);
    res.status(500).json({ error: 'Failed to fetch daily analytics' });
  }
});

// ── Per-Subject Performance ─────────────────────────────────────────────────
router.get('/performance', async (_req, res) => {
  try {
    const result = await db.query(`
      SELECT
        s.name AS subject,
        s.slug,
        COUNT(up.id) AS total_students,
        COALESCE(AVG(up.progress_percent), 0) AS avg_progress,
        COALESCE(
          AVG(CASE WHEN up.questions_answered > 0
            THEN (up.correct_answers::float / up.questions_answered) * 100
            ELSE 0 END
          ), 0
        ) AS avg_accuracy
      FROM subjects s
      LEFT JOIN user_progress up ON up.subject_id = s.id
      GROUP BY s.id, s.name, s.slug
      ORDER BY s.name
    `);

    res.json({
      subjects: result.rows.map((r) => ({
        name: r.subject,
        slug: r.slug,
        students: parseInt(r.total_students),
        avgProgress: parseFloat(r.avg_progress).toFixed(1),
        avgAccuracy: parseFloat(r.avg_accuracy).toFixed(1),
      })),
    });
  } catch (err) {
    console.error('Performance analytics error:', err.message);
    res.status(500).json({ error: 'Failed to fetch performance data' });
  }
});

// ── 7-Day Retention ─────────────────────────────────────────────────────────
router.get('/retention', async (_req, res) => {
  try {
    const result = await db.query(`
      WITH daily_users AS (
        SELECT DISTINCT player1_id AS user_id, DATE(created_at) AS play_date
        FROM duels
        WHERE created_at >= NOW() - INTERVAL '14 days'
      ),
      retention AS (
        SELECT
          d1.play_date AS cohort_date,
          COUNT(DISTINCT d1.user_id) AS cohort_size,
          COUNT(DISTINCT d2.user_id) AS returned_next_day
        FROM daily_users d1
        LEFT JOIN daily_users d2
          ON d1.user_id = d2.user_id
          AND d2.play_date = d1.play_date + INTERVAL '1 day'
        GROUP BY d1.play_date
        ORDER BY d1.play_date DESC
        LIMIT 7
      )
      SELECT
        cohort_date,
        cohort_size,
        returned_next_day,
        CASE WHEN cohort_size > 0
          THEN ROUND((returned_next_day::numeric / cohort_size) * 100, 1)
          ELSE 0
        END AS retention_rate
      FROM retention
    `);

    res.json({
      period: '7d',
      data: result.rows.map((r) => ({
        date: r.cohort_date,
        cohortSize: parseInt(r.cohort_size),
        returnedNextDay: parseInt(r.returned_next_day),
        retentionRate: parseFloat(r.retention_rate),
      })),
    });
  } catch (err) {
    console.error('Retention analytics error:', err.message);
    res.status(500).json({ error: 'Failed to fetch retention data' });
  }
});

module.exports = router;
