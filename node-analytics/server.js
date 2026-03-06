/**
 * MathQuest Analytics & Notifications Microservice
 * ─────────────────────────────────────────────────
 * Tech: Node.js + Express + Socket.IO + PostgreSQL
 *
 * Responsibilities:
 *  • Real-time leaderboard updates via WebSocket
 *  • Push-style notifications (achievements, streaks)
 *  • Analytics aggregation endpoints (DAU, retention, performance)
 *  • Rate-limited public stats API
 */

require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const analyticsRoutes = require('./routes/analytics');
const notificationRoutes = require('./routes/notifications');
const leaderboardRoutes = require('./routes/leaderboard');
const { authenticateToken } = require('./middleware/auth');
const db = require('./db');

const app = express();
const server = http.createServer(app);

// ── Socket.IO for real-time events ──────────────────────────────────────────
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

// Attach io to app so routes can emit events
app.set('io', io);

// ── Middleware ───────────────────────────────────────────────────────────────
app.use(helmet());
app.use(cors());
app.use(morgan('short'));
app.use(express.json());

// Rate limiter — 100 requests per 15 minutes per IP
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, try again later.' },
});
app.use('/api/', limiter);

// ── Routes ──────────────────────────────────────────────────────────────────
app.use('/api/analytics', authenticateToken, analyticsRoutes);
app.use('/api/notifications', authenticateToken, notificationRoutes);
app.use('/api/leaderboard-live', leaderboardRoutes);

// Health check
app.get('/', (_req, res) => {
  res.json({
    service: 'mathquest-analytics',
    version: '1.0.0',
    status: 'running',
    tech: 'Node.js + Express + Socket.IO + PostgreSQL',
  });
});

// ── Socket.IO connections ───────────────────────────────────────────────────
io.on('connection', (socket) => {
  console.log(`🔌 Client connected: ${socket.id}`);

  // Join a room for real-time leaderboard
  socket.on('join-leaderboard', () => {
    socket.join('leaderboard');
    console.log(`📊 ${socket.id} joined leaderboard room`);
  });

  // Join personal notification room
  socket.on('join-user', (userId) => {
    socket.join(`user-${userId}`);
    console.log(`👤 ${socket.id} joined user room: ${userId}`);
  });

  // Duel completion — broadcast to leaderboard
  socket.on('duel-completed', async (data) => {
    try {
      const { userId, score, subject } = data;
      io.to('leaderboard').emit('leaderboard-update', {
        userId,
        score,
        subject,
        timestamp: new Date().toISOString(),
      });

      // Record event in analytics
      await db.query(
        `INSERT INTO analytics_events (event_type, user_id, payload, created_at)
         VALUES ($1, $2, $3, NOW())`,
        ['duel_completed', userId, JSON.stringify(data)]
      );
    } catch (err) {
      console.error('Error processing duel-completed:', err.message);
    }
  });

  socket.on('disconnect', () => {
    console.log(`🔌 Client disconnected: ${socket.id}`);
  });
});

// ── Error handler ───────────────────────────────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// ── Start ───────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`\n🚀 MathQuest Analytics running on http://localhost:${PORT}`);
  console.log(`   WebSocket ready for real-time events\n`);
});

module.exports = { app, server, io };
