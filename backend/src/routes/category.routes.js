const express = require('express');
const router = express.Router();
const { getCategories } = require('../controllers/restaurant.controller');

router.get('/', getCategories);

module.exports = router;