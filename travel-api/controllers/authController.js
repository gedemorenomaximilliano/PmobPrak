const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Generate JWT Token
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRE
    });
};

// Register User
const register = async (req, res) => {
    const { username, email, no_tlp, password, nama_lengkap, jenis_kelamin, tanggal_lahir } = req.body;

    try {
        // Check if user exists
        const [existing] = await db.query(
            'SELECT id_user FROM users WHERE email = ? OR username = ?',
            [email, username]
        );

        if (existing.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'User already exists with this email or username'
            });
        }

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Insert user
        const [result] = await db.query(
            `INSERT INTO users 
            (username, email, no_tlp, password, nama_lengkap, jenis_kelamin, tanggal_lahir, membership_level) 
            VALUES (?, ?, ?, ?, ?, ?, ?, 'Regular')`,
            [username, email, no_tlp, hashedPassword, nama_lengkap, jenis_kelamin, tanggal_lahir]
        );

        const token = generateToken(result.insertId);

        res.status(201).json({
            success: true,
            token,
            user: {
                id: result.insertId,
                username,
                email,
                nama_lengkap
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// Login User
const login = async (req, res) => {
    const { email, password } = req.body;

    try {
        // Get user by email
        const [users] = await db.query(
            'SELECT * FROM users WHERE email = ? OR username = ?',
            [email, email]
        );

        if (users.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        const user = users[0];

        // Check password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        const token = generateToken(user.id_user);

        res.json({
            success: true,
            token,
            user: {
                id: user.id_user,
                username: user.username,
                email: user.email,
                nama_lengkap: user.nama_lengkap,
                membership_level: user.membership_level
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

// Get User Profile
const getUserProfile = async (req, res) => {
    try {
        const [users] = await db.query(
            `SELECT id_user, username, email, no_tlp, nama_lengkap, 
                    membership_level, jenis_kelamin, tanggal_labor, created_at 
             FROM users WHERE id_user = ?`,
            [req.user.id]
        );

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            user: users[0]
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

module.exports = { register, login, getUserProfile };