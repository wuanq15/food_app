/**
 * Chạy file này một lần để tạo bảng và seed data:
 *   node src/utils/setupDB.js
 *
 * Yêu cầu: đã cấu hình .env đúng
 */

require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const fs = require('fs');
const path = require('path');
const sql = require('mssql');

const connectionString =
  `Server=(LocalDB)\\MSSQLLocalDB;` +
  `Trusted_Connection=Yes;` +
  `TrustServerCertificate=Yes;`;


const runSqlFile = async (pool, filePath) => {
  const content = fs.readFileSync(filePath, 'utf8');
  // Tách theo GO statement
  const batches = content.split(/^\s*GO\s*$/im).filter((b) => b.trim());
  for (const batch of batches) {
    if (batch.trim()) {
      await pool.request().query(batch);
    }
  }
};

const setup = async () => {
  let pool;
  try {
    console.log('🔌 Connecting to SQL Server...');
    pool = await sql.connect(connectionString);
    console.log('✅ Connected!\n');

    const schemaPath = path.join(__dirname, '../config/schema.sql');
    const seedPath   = path.join(__dirname, '../config/seed.sql');

    console.log('📋 Running schema.sql...');
    await runSqlFile(pool, schemaPath);
    console.log('✅ Schema created!\n');

    console.log('🌱 Running seed.sql...');
    await runSqlFile(pool, seedPath);
    console.log('✅ Seed data inserted!\n');

    console.log('🎉 Database setup complete! You can now run: node index.js');
  } catch (err) {
    console.error('❌ Setup failed:', err.message);
    console.error('\nKiểm tra lại:');
    console.error('  1. SQL Server đang chạy chưa?');
    console.error('  2. File .env đã cấu hình đúng DB_SERVER, DB_USER, DB_PASSWORD chưa?');
    console.error('  3. User có quyền CREATE DATABASE không?');
  } finally {
    if (pool) await pool.close();
    process.exit(0);
  }
};

setup();