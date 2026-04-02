const db = require('../config/database');

// Create payment
const createPayment = async (req, res) => {
    const { id_order, metode_pembayaran, total_bayar } = req.body;
    const userId = req.user.id;

    try {
        // Verify order belongs to user
        const [orders] = await db.query(
            'SELECT * FROM orders WHERE id_order = ? AND id_user = ?',
            [id_order, userId]
        );

        if (orders.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        // Generate virtual account number
        const virtualAccount = `881${Date.now()}${Math.floor(Math.random() * 1000)}`;
        
        // Set expiry (24 hours from now)
        const expiredTime = new Date();
        expiredTime.setHours(expiredTime.getHours() + 24);

        // Create payment record
        const [paymentResult] = await db.query(
            `INSERT INTO payments 
             (id_order, metode_pembayaran, virtual_account, total_bayar, 
              status_payment, tanggal_payment, expired_time) 
             VALUES (?, ?, ?, ?, 'pending', NOW(), ?)`,
            [id_order, metode_pembayaran, virtualAccount, total_bayar, expiredTime]
        );

        res.status(201).json({
            success: true,
            message: 'Payment created',
            payment: {
                id: paymentResult.insertId,
                virtual_account: virtualAccount,
                expired_time: expiredTime
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// Get payment by order ID
const getPaymentByOrder = async (req, res) => {
    const { orderId } = req.params;
    const userId = req.user.id;

    try {
        const [payments] = await db.query(
            `SELECT p.* 
             FROM payments p
             JOIN orders o ON p.id_order = o.id_order
             WHERE p.id_order = ? AND o.id_user = ?`,
            [orderId, userId]
        );

        if (payments.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Payment not found'
            });
        }

        res.json({
            success: true,
            data: payments[0]
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// Update payment status
const updatePaymentStatus = async (req, res) => {
    const { id } = req.params;
    const { status_payment } = req.body;

    try {
        await db.query(
            'UPDATE payments SET status_payment = ? WHERE id_payment = ?',
            [status_payment, id]
        );

        // If payment is successful, update order status
        if (status_payment === 'success') {
            const [payments] = await db.query(
                'SELECT id_order FROM payments WHERE id_payment = ?',
                [id]
            );
            
            if (payments.length > 0) {
                await db.query(
                    'UPDATE orders SET status_order = "confirmed" WHERE id_order = ?',
                    [payments[0].id_order]
                );
            }
        }

        res.json({
            success: true,
            message: 'Payment status updated'
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

module.exports = { createPayment, getPaymentByOrder, updatePaymentStatus };