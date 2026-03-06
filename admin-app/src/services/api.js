/**
 * API Service — connects to both FastAPI backend & Node.js analytics service
 */
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Base URLs — change for production
const FASTAPI_URL = 'http://localhost:8000/api/v1';
const ANALYTICS_URL = 'http://localhost:3001/api';

// ── Axios instances ─────────────────────────────────────────────────────────
const fastapi = axios.create({ baseURL: FASTAPI_URL, timeout: 10000 });
const analytics = axios.create({ baseURL: ANALYTICS_URL, timeout: 10000 });

// Attach token to every request
const attachToken = async (config) => {
  const token = await AsyncStorage.getItem('admin_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
};

fastapi.interceptors.request.use(attachToken);
analytics.interceptors.request.use(attachToken);

// ── Auth ────────────────────────────────────────────────────────────────────
export const login = async (email, password) => {
  const form = new URLSearchParams();
  form.append('username', email);
  form.append('password', password);
  const res = await fastapi.post('/auth/login', form.toString(), {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });
  await AsyncStorage.setItem('admin_token', res.data.access_token);
  return res.data;
};

// ── FastAPI Endpoints ───────────────────────────────────────────────────────
export const getQuestions = (subjectSlug) =>
  fastapi.get('/questions/', { params: { subject_slug: subjectSlug } });

export const getSubjects = () => fastapi.get('/questions/subjects');

export const getLeaderboard = () => fastapi.get('/leaderboard/');

export const getProfile = () => fastapi.get('/profile/');

// ── Node.js Analytics Endpoints ─────────────────────────────────────────────
export const getAnalyticsOverview = () => analytics.get('/analytics/overview');

export const getDailyAnalytics = () => analytics.get('/analytics/daily');

export const getPerformanceAnalytics = () => analytics.get('/analytics/performance');

export const getRetentionAnalytics = () => analytics.get('/analytics/retention');

export const getLiveLeaderboard = () => analytics.get('/leaderboard-live/top');

// ── Notifications ───────────────────────────────────────────────────────────
export const getNotifications = () => analytics.get('/notifications');

export const sendNotification = (userId, title, message, type = 'info') =>
  analytics.post('/notifications/send', { userId, title, message, type });

export const broadcastNotification = (title, message) =>
  analytics.post('/notifications/broadcast', { title, message });

export default { fastapi, analytics };
