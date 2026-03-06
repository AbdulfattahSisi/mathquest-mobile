/**
 * Real-Time Leaderboard Routes
 * GET /api/leaderboard-live/top     → top 20 players (public, no auth)
 * GET /api/leaderboard-live/stream  → SSE stream for live updates
 */

const express = require('express');
const router = express.Router();
const db = require('../db');
const { optionalAuth } = require('../middleware/auth');

// ── Top Players (public) ────────────────────────────────────────────────────
router.get('/top', optionalAuth, async (_req, res) => {
  try {
    const result = await db.query(`
      SELECT
        u.id,
        u.username,
        u.total_points,
        u.level,
        u.streak_days,
        u.avatar_url,
        COUNT(d.id) AS total_duels,
        SUM(CASE WHEN d.winner_id = u.id THEN 1 ELSE 0 END) AS wins
      FROM users u
      LEFT JOIN duels d ON d.player1_id = u.id AND d.status = 'finished'
      GROUP BY u.id
      ORDER BY u.total_points DESC
      LIMIT 20
    `);

    res.json({
      leaderboard: result.rows.map((r, i) => ({
        rank: i + 1,
        id: r.id,
        username: r.username,
        totalPoints: r.total_points,
        level: r.level,
        streakDays: r.streak_days,
        avatarUrl: r.avatar_url,
        totalDuels: parseInt(r.total_duels),
        wins: parseInt(r.wins),
      })),
      updatedAt: new Date().toISOString(),
    });
  } catch (err) {
    console.error('Leaderboard error:', err.message);
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

// ── Server-Sent Events Stream ───────────────────────────────────────────────
router.get('/stream', (_req, res) => {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    Connection: 'keep-alive',
  });

  res.write('data: {"type":"connected"}\n\n');

  // Send leaderboard update every 30 seconds
  const interval = setInterval(async () => {
    try {
      const result = await db.query(`
        SELECT u.username, u.total_points, u.level
        FROM users u
        ORDER BY u.total_points DESC
        LIMIT 10
      `);
      res.write(`data: ${JSON.stringify({ type: 'update', leaderboard: result.rows })}\n\n`);
    } catch (_) {
      // Silently ignore DB errors in SSE
    }
  }, 30000);

  _req.on('close', () => {
    clearInterval(interval);
  });
});

module.exports = router;
