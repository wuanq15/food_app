const express = require('express');
const orderRouter = express.Router();
const profileRouter = express.Router();
 
const { createOrder, getOrderHistory, getOrderById } = require('../controllers/order.controller');
const { getProfile, updateProfile, changePassword } = require('../controllers/profile.controller');
const { verifyToken } = require('../middleware/auth.middleware');
 
// Tất cả order routes đều cần xác thực
orderRouter.post('/',         verifyToken, createOrder);
orderRouter.get('/history',   verifyToken, getOrderHistory);
orderRouter.get('/:id',       verifyToken, getOrderById);
 
// Profile routes
profileRouter.get('/',          verifyToken, getProfile);
profileRouter.put('/',          verifyToken, updateProfile);
profileRouter.put('/password',  verifyToken, changePassword);
 
module.exports = { orderRouter, profileRouter };