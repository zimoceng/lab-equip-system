const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// 最小可用：先不连数据库，保证服务能跑
app.get("/api/health", (req, res) => {
  res.json({ ok: true, msg: "server is running" });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`API listening on http://127.0.0.1:${PORT}`);
});
