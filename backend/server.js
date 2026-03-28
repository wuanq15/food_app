const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const foodRoutes = require('./routes/foodRoutes');

const app = express();

// Init Middleware
app.use(cors());
app.use(express.json({ extended: false }));

app.get('/api/health', (req, res) => {
  res.json({ ok: true, service: 'appfood-api' });
});

// Define Routes
app.use('/api/auth', authRoutes);
app.use('/api/food', foodRoutes);

app.get('/', (req, res) => {
  res.send('AppFood API is running...');
});

// Mặc định 5050: macOS AirPlay Receiver hay chiếm 5000 và trả 403 cho HTTP.
const PORT = process.env.PORT || 5050;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server started on port ${PORT} (http://localhost:${PORT})`);
});
