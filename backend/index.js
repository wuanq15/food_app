require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { getPool, closePool } = require('./src/config/database');

// Routes
const authRoutes = require('./src/routes/auth.routes');
const restaurantRoutes = require('./src/routes/restaurant.routes');
const menuRoutes = require('./src/routes/menu.routes');
const { orderRouter, profileRouter } = require('./src/routes/index');

const app = express();
const PORT = process.env.PORT || 3000;

// ─── Middleware ────────────────────────────────────────────────
app.use(cors({
  origin: '*', // development - production thay bằng domain thực
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ─── Routes ────────────────────────────────────────────────────
app.use('/api/auth',         authRoutes);
app.use('/api/restaurants',  restaurantRoutes);
app.use('/api/categories',   require('./src/routes/category.routes'));
app.use('/api/menu',         menuRoutes);
app.use('/api/orders',       orderRouter);
app.use('/api/profile',      profileRouter);

// ─── Health check ──────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Food App API is running',
    timestamp: new Date().toISOString(),
  });
});

// ─── 404 handler ───────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.method} ${req.path} not found` });
});

// ─── Global error handler ──────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ success: false, message: 'Lỗi server không xác định' });
});

// ─── Start server ──────────────────────────────────────────────
const start = async () => {
  try {
    await getPool(); // Kết nối DB trước khi nhận request
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`📋 API docs:`);
      console.log(`   POST /api/auth/register`);
      console.log(`   POST /api/auth/login`);
      console.log(`   GET  /api/auth/me`);
      console.log(`   GET  /api/restaurants`);
      console.log(`   GET  /api/restaurants/:id`);
      console.log(`   GET  /api/restaurants/:id/menu`);
      console.log(`   GET  /api/restaurants/recommend?lat=&lng=`);
      console.log(`   GET  /api/categories`);
      console.log(`   POST /api/orders`);
      console.log(`   GET  /api/orders/history`);
      console.log(`   GET  /api/orders/:id`);
      console.log(`   GET  /api/profile`);
      console.log(`   PUT  /api/profile`);
      console.log(`   PUT  /api/profile/password`);
    });
  } catch (err) {
    console.error('❌ Failed to start server:', err.message);
    process.exit(1);
  }
};

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🛑 Shutting down...');
  await closePool();
  process.exit(0);
});

start();