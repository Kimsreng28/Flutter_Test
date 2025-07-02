const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const productsRoutes = require("./routes/products");
const { query } = require("./config/db");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware to parse JSON requests
app.use(cors());
app.use(express.json());
app.use(express.static("public"));

// Test Routes
app.get("/", (req, res) => {
  res.send("API is running. Try /api/products or /db-test.");
});

// Test database connection
app.get("/db-test", async (req, res) => {
  try {
    const result = await query("SELECT DB_NAME() AS connected_database");
    res.json({
      success: true,
      connectedTo: result.recordset[0].connected_database,
    });
  } catch (err) {
    console.error("DB test failed", err);
    res
      .status(500)
      .json({ success: false, error: "Database connection failed" });
  }
});

// Products routes
app.use("/api/products", productsRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: "Internal server error" });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
