const jwt = require('jsonwebtoken');

/** Gắn req.user nếu có Bearer hợp lệ; không có token vẫn next() (khách). */
module.exports = function optionalAuth(req, res, next) {
  const authHeader = req.header('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next();
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'super_secret_jwt_key_for_appfood_2024',
    );
    req.user = decoded.user;
  } catch (_) {
    req.user = undefined;
  }
  next();
};
