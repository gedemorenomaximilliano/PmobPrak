const express = require('express');
const router = express.Router();
const { 
    createPayment, 
    getPaymentByOrder,
    updatePaymentStatus 
} = require('../controllers/paymentController');
const { protect } = require('../middleware/auth');

router.post('/', protect, createPayment);
router.get('/order/:orderId', protect, getPaymentByOrder);
router.put('/:id/status', protect, updatePaymentStatus);

module.exports = router;