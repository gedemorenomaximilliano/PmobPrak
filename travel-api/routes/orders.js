const express = require('express');
const router = express.Router();
const { 
    createOrder, 
    getUserOrders, 
    getOrderById,
    updateOrderStatus 
} = require('../controllers/orderController');
const { protect } = require('../middleware/auth');

router.post('/', protect, createOrder);
router.get('/', protect, getUserOrders);
router.get('/:id', protect, getOrderById);
router.put('/:id/status', protect, updateOrderStatus);

module.exports = router;