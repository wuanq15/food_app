const express = require('express');
const router = express.Router();
const {
  getRestaurants,
  getRestaurantById,
  getRestaurantMenu,
  getCategories,
  getRecommendations,
} = require('../controllers/restaurant.controller');

router.get('/',              getRestaurants);
router.get('/recommend',     getRecommendations);   // phải trước /:id
router.get('/:id',           getRestaurantById);
router.get('/:id/menu',      getRestaurantMenu);

module.exports = router;