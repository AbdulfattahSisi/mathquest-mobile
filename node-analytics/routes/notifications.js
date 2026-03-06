/**
 * Notification Routes — Push-style notifications via REST + WebSocket
 * GET  /api/notifications           → fetch user notifications
 * POST /api/notifications/send      → admin sends a notification
 * POST /api/notifications/read/:id  → mark notification as read
 * POST /api/notifications/broadcast → broadcast to all connected users
 */

const express = require('express');
const router = express.Router();
const db = require('../db');

// ── Get User Notifications ──────────────────────────────────────────────────
router.get('/', async (req, res) => {
  try {
    const userId = req.user.sub || req.user.id;
    const result = await db.query(
      `SELECT id, title, message, type, is_read, created_at
       FROM notifications
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT 50`,
      [userId]
    );

    const unreadCount = result.rows.filter((n) => !n.is_read).length;

    res.json({
      notifications: result.rows,
      unreadCount,
    });
  } catch (err) {
    console.error('Fetch notifications error:', err.message);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

// ── Send Notification (admin or system) ─────────────────────────────────────
router.post('/send', async (req, res) => {
  try {
    const { userId, title, message, type = 'info' } = req.body;

    if (!userId || !title || !message) {
      return res.status(400).json({ error: 'userId, title, and message are required' });
    }

    const result = await db.query(
      `INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
       VALUES ($1, $2, $3, $4, false, NOW())
       RETURNING id, title, message, type, created_at`,
      [userId, title, message, type]
    );

    const notification = result.rows[0];

    // Emit real-time notification via WebSocket
    const io = req.app.get('io');
    io.to(`user-${userId}`).emit('new-notification', notification);

    res.status(201).json({ notification });
  } catch (err) {
    console.error('Send notification error:', err.message);
    res.status(500).json({ error: 'Failed to send notification' });
  }
});

// ── Mark as Read ────────────────────────────────────────────────────────────
router.post('/read/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.sub || req.user.id;

    await db.query(
      `UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );

    res.json({ success: true });
  } catch (err) {
    console.error('Mark read error:', err.message);
    res.status(500).json({ error: 'Failed to mark notification as read' });
  }
});

// ── Broadcast to All Connected Users ────────────────────────────────────────
router.post('/broadcast', async (req, res) => {
  try {
    const { title, message, type = 'announcement' } = req.body;

    if (!title || !message) {
      return res.status(400).json({ error: 'title and message are required' });
    }

    const io = req.app.get('io');
    io.emit('broadcast', { title, message, type, timestamp: new Date().toISOString() });

    res.json({ success: true, message: 'Broadcast sent to all connected clients' });
  } catch (err) {
    console.error('Broadcast error:', err.message);
    res.status(500).json({ error: 'Failed to broadcast' });
  }
});

module.exports = router;
