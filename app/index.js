const express = require("express");
const os = require("os");
const { pool, init } = require("./db");

const app = express();
app.use(express.json());

app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

async function logRequest(endpoint) {
  try {
    await pool.query("INSERT INTO logs(endpoint) VALUES($1)", [endpoint]);
  } catch (err) {
    console.error("Failed to log request:", err);
  }
}

app.get("/", async (req, res) => {
  await logRequest("/");
  res.status(200).json({
    message: "Welcome to Francis's nodejs application",
    availableEndpoints: [
      "GET /health",
      "GET /status",
      "POST /process",
      "GET /logs"
    ]
  });
});

app.get("/health", async (req, res) => {
  await logRequest("/health");
  try {
    await pool.query("SELECT 1");
    console.log("Health check passed - DB connected");
    res.json({ status: "ok", db: "connected" });
  } catch (err) {
    console.error("Health check failed - DB unreachable:", err.message);
    res.status(503).json({ status: "error", db: "unreachable" });
  }
});

app.get("/status", async (req, res) => {
  await logRequest("/status");
  const statusData = {
    uptime: process.uptime(),
    hostname: os.hostname(),
    timestamp: new Date()
  };
  console.log("Status requested:", statusData);
  res.json(statusData);
});

app.post("/process", async (req, res) => {
  await logRequest("/process");
  const payload = req.body;
  console.log("Processing payload:", payload);
  try {
    res.json({ message: "Processed successfully", data: payload });
    console.log("Payload processed successfully");
  } catch (err) {
    console.error("Process error:", err.message);
    res.status(500).json({ error: "Failed to process request" });
  }
});

app.get("/logs", async (req, res) => {
  await logRequest("/logs");
  try {
    const result = await pool.query("SELECT * FROM logs ORDER BY id DESC");
    console.log(`Fetched ${result.rows.length} log entries`);
    res.json(result.rows);
  } catch (err) {
    console.error("DB fetch error:", err.message);
    res.status(500).json({ error: "Failed to fetch logs" });
  }
});

app.use((req, res) => {
  console.warn(`404 - Route not found: ${req.method} ${req.url}`);
  res.status(404).json({
    error: "Route not found",
    availableEndpoints: [
      "GET /health",
      "GET /status",
      "POST /process",
      "GET /logs"
    ]
  });
});

if (process.env.NODE_ENV !== "test") {
  init()
    .then(() => {
      const PORT = process.env.PORT || 3000;
      app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
        console.log(`Environment: ${process.env.NODE_ENV || "development"}`);
        console.log(`DB Host: ${process.env.DB_HOST}`);
      });
    })
    .catch(err => {
      console.error("Failed to initialize DB:", err.message);
      process.exit(1);
    });
}

module.exports = app;