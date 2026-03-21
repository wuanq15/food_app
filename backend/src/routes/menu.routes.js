const express = require('express');
const router = express.Router();
const { getMenuItemById } = require('../controllers/restaurant.controller');

// GET /api/menu/:id – chi tiết một món ăn
router.get('/:id', getMenuItemById);

module.exports = router;
