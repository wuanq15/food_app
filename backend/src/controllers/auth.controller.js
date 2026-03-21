const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { sql, getPool } = require('../config/database');

// ─── Helper tạo JWT ─────────────────────────────────────────
const signToken = (user) => {
  return jwt.sign(
    { id: user.id, email: user.email, name: user.name },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

// ─── POST /api/auth/register ─────────────────────────────────
const register = async (req, res) => {
  const { name, email, phone, password, address } = req.body;

  // Validate
  if (!name || !email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng điền đầy đủ họ tên, email và mật khẩu',
    });
  }

  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'Mật khẩu phải có ít nhất 6 ký tự',
    });
  }

  try {
    const pool = await getPool();

    // Kiểm tra email đã tồn tại
    const existing = await pool.request()
      .input('email', sql.NVarChar, email.toLowerCase().trim())
      .query('SELECT id FROM Users WHERE email = @email');

    if (existing.recordset.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Email này đã được sử dụng',
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Insert user
    const result = await pool.request()
      .input('name',     sql.NVarChar, name.trim())
      .input('email',    sql.NVarChar, email.toLowerCase().trim())
      .input('phone',    sql.NVarChar, phone || null)
      .input('password', sql.NVarChar, hashedPassword)
      .input('address',  sql.NVarChar, address || null)
      .query(`
        INSERT INTO Users (name, email, phone, password, address)
        OUTPUT INSERTED.id, INSERTED.name, INSERTED.email, INSERTED.phone,
               INSERTED.avatar_url, INSERTED.address, INSERTED.created_at
        VALUES (@name, @email, @phone, @password, @address)
      `);

    const newUser = result.recordset[0];
    const token = signToken(newUser);

    return res.status(201).json({
      success: true,
      message: 'Đăng ký thành công',
      data: {
        token,
        user: {
          id: newUser.id,
          name: newUser.name,
          email: newUser.email,
          phone: newUser.phone,
          avatar_url: newUser.avatar_url,
          address: newUser.address,
        },
      },
    });
  } catch (err) {
    console.error('Register error:', err);
    return res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại',
    });
  }
};

// ─── POST /api/auth/login ────────────────────────────────────
const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng nhập email và mật khẩu',
    });
  }

  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('email', sql.NVarChar, email.toLowerCase().trim())
      .query(`
        SELECT id, name, email, phone, password, avatar_url, address, is_active
        FROM Users
        WHERE email = @email
      `);

    const user = result.recordset[0];

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Email hoặc mật khẩu không đúng',
      });
    }

    if (!user.is_active) {
      return res.status(403).json({
        success: false,
        message: 'Tài khoản đã bị khóa, vui lòng liên hệ hỗ trợ',
      });
    }

    // So sánh password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Email hoặc mật khẩu không đúng',
      });
    }

    const token = signToken(user);

    return res.status(200).json({
      success: true,
      message: 'Đăng nhập thành công',
      data: {
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          avatar_url: user.avatar_url,
          address: user.address,
        },
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({
      success: false,
      message: 'Lỗi server, vui lòng thử lại',
    });
  }
};

// ─── GET /api/auth/me ────────────────────────────────────────
const getMe = async (req, res) => {
  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('id', sql.Int, req.user.id)
      .query(`
        SELECT id, name, email, phone, avatar_url, address, created_at
        FROM Users
        WHERE id = @id AND is_active = 1
      `);

    const user = result.recordset[0];
    if (!user) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
    }

    return res.status(200).json({ success: true, data: user });
  } catch (err) {
    console.error('GetMe error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

module.exports = { register, login, getMe };