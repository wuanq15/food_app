const sql = require('mssql/msnodesqlv8');
require('dotenv').config();

// Với mssql v9 + package mssql/msnodesqlv8:
// Đây là cách tốt nhất để dùng Windows Authentication với LocalDB
const config = {
  connectionString: 'Driver={ODBC Driver 17 for SQL Server};Server=(localdb)\\MSSQLLocalDB;Database=FoodAppDB;Trusted_Connection=yes;',
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

let pool = null;

const getPool = async () => {
  if (pool) return pool;
  try {
    pool = await new sql.ConnectionPool(config).connect();
    console.log('✅ Connected to SQL Server (FoodAppDB) via msnodesqlv8');
    return pool;
  } catch (err) {
    console.error('❌ DB connection failed:', err.message);
    throw err;
  }
};

const closePool = async () => {
  if (pool) {
    await pool.close();
    pool = null;
    console.log('🔌 SQL Server connection closed');
  }
};

module.exports = { sql, getPool, closePool };