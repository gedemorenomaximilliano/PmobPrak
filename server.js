const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Database connection - FIXED VERSION
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'MobPrakDatabase',
    port: 3306
});

// Connect to database
db.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err);
        return;
    }
    console.log('Connected to MobPrakDatabase');
});

// Test route
app.get('/', (req, res) => {
    res.json({ message: 'API is working!' });
});

// Get all destinations
app.get('/api/destinations', (req, res) => {
    db.query('SELECT * FROM destinations', (err, results) => {
        if (err) {
            console.error('Query error:', err);
            res.status(500).json({ success: false, error: err.message });
            return;
        }
        res.json({ success: true, data: results });
    });
});

// Get popular destinations
app.get('/api/destinations/popular', (req, res) => {
    db.query('SELECT * FROM destinations ORDER BY rating DESC LIMIT 5', (err, results) => {
        if (err) {
            res.status(500).json({ success: false, error: err.message });
            return;
        }
        res.json({ success: true, data: results });
    });
});

// Get destination by ID
app.get('/api/destinations/:id', (req, res) => {
    db.query('SELECT * FROM destinations WHERE id_destination = ?', [req.params.id], (err, results) => {
        if (err) {
            res.status(500).json({ success: false, error: err.message });
            return;
        }
        res.json({ success: true, data: results[0] });
    });
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
