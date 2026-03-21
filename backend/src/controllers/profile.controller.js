const bcrypt = require('bcryptjs');
const { sql, getPool } = require('../config/database');

// ─── GET /api/profile ─────────────────────────────────────────
const getProfile = async (req, res) => {
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
    console.error('GetProfile error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// ─── PUT /api/profile ─────────────────────────────────────────
const updateProfile = async (req, res) => {
  const { name, phone, address } = req.body;

  if (!name || name.trim().length === 0) {
    return res.status(400).json({ success: false, message: 'Tên không được để trống' });
  }

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id',      sql.Int,      req.user.id)
      .input('name',    sql.NVarChar, name.trim())
      .input('phone',   sql.NVarChar, phone || null)
      .input('address', sql.NVarChar, address || null)
      .query(`
        UPDATE Users
        SET name = @name, phone = @phone, address = @address, updated_at = GETDATE()
        OUTPUT INSERTED.id, INSERTED.name, INSERTED.email,
               INSERTED.phone, INSERTED.address, INSERTED.avatar_url
        WHERE id = @id
      `);

    return res.status(200).json({
      success: true,
      message: 'Cập nhật thông tin thành công',
      data: result.recordset[0],
    });
  } catch (err) {
    console.error('UpdateProfile error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// ─── PUT /api/profile/password ────────────────────────────────
const changePassword = async (req, res) => {
  const { current_password, new_password } = req.body;

  if (!current_password || !new_password) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng nhập mật khẩu hiện tại và mật khẩu mới',
    });
  }

  if (new_password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'Mật khẩu mới phải có ít nhất 6 ký tự',
    });
  }

  try {
    const pool = await getPool();

    // Lấy password hiện tại
    const userResult = await pool.request()
      .input('id', sql.Int, req.user.id)
      .query('SELECT password FROM Users WHERE id = @id');

    const user = userResult.recordset[0];
    const isMatch = await bcrypt.compare(current_password, user.password);

    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Mật khẩu hiện tại không đúng',
      });
    }

    const hashed = await bcrypt.hash(new_password, 12);

    await pool.request()
      .input('id',       sql.Int,      req.user.id)
      .input('password', sql.NVarChar, hashed)
      .query('UPDATE Users SET password = @password, updated_at = GETDATE() WHERE id = @id');

    return res.status(200).json({ success: true, message: 'Đổi mật khẩu thành công' });
  } catch (err) {
    console.error('ChangePassword error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

module.exports = { getProfile, updateProfile, changePassword };