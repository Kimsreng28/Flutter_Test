const sql = require("mssql");
const dotenv = require("dotenv");

dotenv.config();

// Database configuration
const dbConfig = {
  server: process.env.DB_SERVER,
  port: parseInt(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
};

const pool = new sql.ConnectionPool(dbConfig);
const poolConnect = pool.connect();

// Function to execute a SQL query
async function query(sqlQuery, params = {}) {
  await poolConnect;
  try {
    const request = pool.request();

    // Add input parameters
    for (const key in params) {
      request.input(key, params[key]);
    }

    const result = await request.query(sqlQuery);
    return result;
  } catch (err) {
    console.error("SQL error", err);
    throw err;
  }
}

// Function to close the database connection pool
async function closePool() {
  try {
    await pool.close();
  } catch (err) {
    console.error("Error closing the pool", err);
  }
}

module.exports = {
  query,
  closePool,
};
