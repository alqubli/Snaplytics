#!/usr/bin/env bash
set -euo pipefail

ROOT="Snaplytics"
ZIPNAME="Snaplytics.zip"

echo "Starting Snaplytics project generator..."

# Clean previous
rm -rf "$ROOT" "$ZIPNAME"
mkdir -p "$ROOT/frontend/public"
mkdir -p "$ROOT/frontend/src"
mkdir -p "$ROOT/backend"

# ---------- Create frontend files ----------
cat > "$ROOT/frontend/package.json" <<'EOF'
{
  "name": "snaplytics-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "chart.js": "^4.4.0",
    "react-chartjs-2": "^5.2.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build"
  }
}
EOF

cat > "$ROOT/frontend/public/index.html" <<'EOF'
<!doctype html>
<html lang="ar">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Snaplytics</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOF

cat > "$ROOT/frontend/src/index.js" <<'EOF'
import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import "./index.css";

const container = document.getElementById("root");
const root = createRoot(container);
root.render(<App />);
EOF

cat > "$ROOT/frontend/src/index.css" <<'EOF'
:root{
  --bg:#0b0b0b;
  --card:#111111;
  --gold:#d4af37;
  --muted:#bfbfbf;
}

*{box-sizing:border-box}
html,body,#root{height:100%;margin:0;font-family:Inter, Arial, sans-serif;background:var(--bg);color:var(--muted)}

.app {
  max-width:1000px;margin:32px auto;padding:24px;background:linear-gradient(180deg, rgba(255,255,255,0.02), transparent);border-radius:12px;box-shadow:0 6px 30px rgba(0,0,0,0.6);
  border:1px solid rgba(212,175,55,0.06);
}

.header {display:flex;align-items:center;justify-content:space-between;margin-bottom:18px}
.brand {display:flex;align-items:center;gap:12px}
.logo {
  width:56px;height:56px;border-radius:10px;background:linear-gradient(135deg,var(--gold),#b8860b);display:flex;align-items:center;justify-content:center;color:#0b0b0b;font-weight:700;font-size:18px;
}
.title {font-size:20px;color:var(--gold);font-weight:700}
.subtitle {font-size:13px;color:var(--muted)}

.controls {display:flex;gap:12px;align-items:center}

.btn {
  background:transparent;border:1px solid rgba(212,175,55,0.18);color:var(--gold);padding:8px 12px;border-radius:8px;cursor:pointer;
}
.btn.primary {background:linear-gradient(90deg, rgba(212,175,55,0.12), rgba(212,175,55,0.06));border:1px solid rgba(212,175,55,0.28)}

.card {background:var(--card);padding:18px;border-radius:10px;border:1px solid rgba(255,255,255,0.02);margin-top:12px}
.row {display:flex;gap:16px;align-items:center}
.small {font-size:13px;color:var(--muted)}
.center {text-align:center}
.footer {margin-top:18px;font-size:12px;color:#8f8f8f}
EOF

cat > "$ROOT/frontend/src/App.js" <<'EOF'
import React, { useEffect, useState } from "react";
import { Chart, registerables } from "chart.js";
import { Line } from "react-chartjs-2";

Chart.register(...registerables);

export default function App(){
  const [status, setStatus] = useState("loading...");
  const [user, setUser] = useState(null);
  const [chartData, setChartData] = useState(null);
  const [recommended, setRecommended] = useState([]);

  useEffect(()=>{
    fetch("/api/health")
      .then(r=>r.json())
      .then(d=>setStatus(d.status))
      .catch(()=>setStatus("offline"));

    setChartData({
      labels: ["Week 1","Week 2","Week 3","Week 4"],
      datasets:[
        {
          label: "Engagement score",
          data: [12, 19, 8, 24],
          borderColor: "#d4af37",
          backgroundColor: "rgba(212,175,55,0.12)",
          tension: 0.3,
          pointRadius:4,
        }
      ]
    });

    fetch("/api/me")
      .then(r=>r.json())
      .then(d=>{ if(d?.id) setUser(d) })
      .catch(()=>{});
  },[]);

  function handleLoginSnap(){
    window.location.href = "/auth/snapchat";
  }

  function handleFetchAnalytics(){
    fetch("/api/analytics")
      .then(r=>r.json())
      .then(d=>{
        setChartData({
          labels: d.summary.labels,
          datasets:[{
            label: "Snaplytics score",
            data: d.summary.values,
            borderColor: "#d4af37",
            backgroundColor: "rgba(212,175,55,0.12)",
            tension: 0.25,
            pointRadius:4
          }]
        });
        setRecommended(d.recommended || []);
      })
      .catch(()=>alert("فشل جلب التحليلات"));
  }

  function handleUploadCSV(e){
    const file = e.target.files[0];
    if(!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      const text = reader.result;
      const lines = text.split(/\r?\n/).filter(Boolean);
      const posts = lines.map(l=>{
        const [timestamp, views] = l.split(",");
        return { timestamp: timestamp.trim(), views: Number(views) };
      });
      fetch("/api/upload-posts", { method: "POST", headers: {"Content-Type":"application/json"}, body: JSON.stringify({ posts }) })
        .then(r=>r.json())
        .then(d=>{
          setChartData({ labels: d.summary.labels, datasets:[{ label: "Snaplytics score", data: d.summary.values, borderColor: "#d4af37", backgroundColor: "rgba(212,175,55,0.12)", tension:0.25 }] });
          setRecommended(d.recommended || []);
        })
        .catch(()=>alert("فشل تحليل الملف"));
    };
    reader.readAsText(file);
  }

  return (
    <div className="app">
      <div className="header">
        <div className="brand">
          <div className="logo">S</div>
          <div>
            <div className="title">Snaplytics</div>
            <div className="subtitle">تحليلات سناب بسيطة وسريعة</div>
          </div>
        </div>

        <div className="controls">
          {user ? (
            <div className="small">مرحباً، <strong style={{color:"#fff"}}>{user.displayName || user.id}</strong></div>
          ) : (
            <button className="btn primary" onClick={handleLoginSnap}>تسجيل دخول سناب</button>
          )}
          <button className="btn" onClick={handleFetchAnalytics}>جلب التحليلات</button>
          <label className="btn" style={{cursor:'pointer'}}>
            رفع CSV
            <input type="file" accept=".csv" style={{display:'none'}} onChange={handleUploadCSV} />
          </label>
        </div>
      </div>

      <div className="card">
        <div className="row">
          <div style={{flex:1}}>
            <div className="small">حالة الخادم</div>
            <div style={{fontSize:18,color:"#fff"}}>{status}</div>
          </div>
          <div style={{width:420}}>
            {chartData ? (
              <Line data={chartData} options={{
                plugins:{legend:{labels:{color:"#d4af37"}}},
                scales:{
                  x:{ticks:{color:"#bfbfbf"}, grid:{color:"rgba(255,255,255,0.02)"}},
                  y:{ticks:{color:"#bfbfbf"}, grid:{color:"rgba(255,255,255,0.02)"}}
                }
              }} />
            ) : (
              <div className="center small">لا توجد بيانات بعد</div>
            )}
          </div>
        </div>

        {recommended && recommended.length > 0 && (
          <div style={{marginTop:12}}>
            <h3 style={{color:"#d4af37"}}>أفضل أوقات النشر</h3>
            <div style={{display:"flex",gap:12}}>
              {recommended.map(r => (
                <div key={r.hour} className="card" style={{flex:1}}>
                  <div style={{fontSize:18,color:"#fff"}}>{r.hour}:00</div>
                  <div className="small">توقع: {r.score}</div>
                  <div className="small">ثقة: {r.confidence}%</div>
                </div>
              ))}
            </div>
          </div>
        )}

      </div>

      <div className="card footer">
        <div>ملاحظة: لتفعيل تسجيل الدخول عبر سناب، تحتاج إعداد تطبيق سناب وتعبئة المتغيرات البيئية في الخادم.</div>
      </div>
    </div>
  );
}
EOF

# ---------- Create backend files ----------
cat > "$ROOT/backend/package.json" <<'EOF'
{
  "name": "snaplytics-backend",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "axios": "^1.4.0",
    "cors": "^2.8.5",
    "express": "^4.18.2",
    "dotenv": "^16.0.3",
    "body-parser": "^1.20.2",
    "moment-timezone": "^0.5.43"
  },
  "devDependencies": {
    "nodemon": "^2.0.22"
  }
}
EOF

cat > "$ROOT/backend/analytics.js" <<'EOF'
const moment = require("moment-timezone");

function analyzePosts(posts, timezone = "UTC") {
  if (!posts || posts.length === 0) {
    return { recommended: [], summary: { labels: [], values: [] } };
  }

  const buckets = Array.from({ length: 24 }, () => ({ count: 0, sumViews: 0 }));

  posts.forEach(p => {
    const t = moment.tz(p.timestamp, timezone);
    const hour = t.hour();
    buckets[hour].count += 1;
    buckets[hour].sumViews += (p.views || 0);
  });

  const avgPerHour = buckets.map((b, h) => {
    const avg = b.count ? b.sumViews / b.count : 0;
    return { hour: h, avg, count: b.count };
  });

  const smoothed = avgPerHour.map((_, i, arr) => {
    const prev = arr[(i + 23) % 24].avg;
    const cur = arr[i].avg;
    const next = arr[(i + 1) % 24].avg;
    return { hour: i, score: (prev + cur + next) / 3, count: arr[i].count };
  });

  const ranked = [...smoothed].sort((a,b) => b.score - a.score);
  const maxCount = Math.max(...smoothed.map(s => s.count), 1);
  const recommended = ranked.slice(0, 3).map(r => ({
    hour: r.hour,
    score: Math.round(r.score * 100) / 100,
    confidence: Math.round((r.count / maxCount) * 100)
  }));

  const labels = smoothed.map(s => `${s.hour}:00`);
  const values = smoothed.map(s => Math.round(s.score * 100) / 100);

  return { recommended, summary: { labels, values } };
}

module.exports = { analyzePosts };
EOF

cat > "$ROOT/backend/server.js" <<'EOF'
require("dotenv").config();
const express = require("express");
const cors = require("cors");
const path = require("path");
const axios = require("axios");
const qs = require("querystring");
const { analyzePosts } = require("./analytics");

const app = express();
app.use(cors());
app.use(express.json());

const sessions = {};

app.get("/api/health", (req, res) => res.json({ status: "ok" }));

app.get("/auth/snapchat", (req, res) => {
  const clientId = process.env.SNAP_CLIENT_ID;
  const redirectUri = process.env.SNAP_REDIRECT_URI;
  const authUrl = process.env.SNAP_AUTH_URL;
  const scope = process.env.SNAP_SCOPE || "user.display_name";

  if (!clientId || !redirectUri || !authUrl) {
    return res.status(500).send("OAuth not configured. Set SNAP_CLIENT_ID, SNAP_REDIRECT_URI, SNAP_AUTH_URL.");
  }

  const params = new URLSearchParams({
    client_id: clientId,
    response_type: "code",
    redirect_uri: redirectUri,
    scope,
    state: "snaplytics_" + Date.now()
  });

  res.redirect(`${authUrl}?${params.toString()}`);
});

app.get("/auth/snapchat/callback", async (req, res) => {
  const { code } = req.query;
  if (!code) return res.status(400).send("Missing code");

  try {
    const tokenResp = await axios.post(process.env.SNAP_TOKEN_URL, qs.stringify({
      grant_type: "authorization_code",
      code,
      redirect_uri: process.env.SNAP_REDIRECT_URI,
      client_id: process.env.SNAP_CLIENT_ID,
      client_secret: process.env.SNAP_CLIENT_SECRET
    }), { headers: { "Content-Type": "application/x-www-form-urlencoded" }});

    const tokenData = tokenResp.data;
    const sessionId = "sess_" + Date.now();
    sessions[sessionId] = { tokenData, createdAt: Date.now() };

    res.redirect(`/auth/success?session=${sessionId}`);
  } catch (err) {
    console.error("Token exchange error:", err.response?.data || err.message);
    res.status(500).send("Token exchange failed");
  }
});

app.get("/api/analytics", async (req, res) => {
  const session = req.query.session;
  if (session && sessions[session]) {
    const token = sessions[session].tokenData.access_token;
    try {
      throw new Error("Real Snapchat fetch not implemented in demo");
    } catch (err) {
      console.warn("Snap fetch failed, returning demo data:", err.message);
    }
  }

  const now = Date.now();
  const posts = [];
  for (let i = 0; i < 120; i++) {
    const ts = new Date(now - Math.floor(Math.random() * 30 * 24 * 3600 * 1000)).toISOString();
    const views = Math.round(50 + Math.random() * 500);
    posts.push({ timestamp: ts, views });
  }

  const result = analyzePosts(posts, process.env.DEFAULT_TIMEZONE || "Asia/Aden");
  res.json(result);
});

app.post("/api/upload-posts", (req, res) => {
  const { posts, timezone } = req.body;
  if (!posts || !Array.isArray(posts)) return res.status(400).json({ error: "posts array required" });

  const result = analyzePosts(posts, timezone || process.env.DEFAULT_TIMEZONE || "Asia/Aden");
  res.json(result);
});

const buildPath = path.join(__dirname, "..", "frontend", "build");
app.use(express.static(buildPath));
app.get("*", (req, res) => {
  if (req.path.startsWith("/api") || req.path.startsWith("/auth")) return res.status(404).json({ error: "Not found" });
  res.sendFile(path.join(buildPath, "index.html"));
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, ()=>console.log(`Backend running on ${PORT}`));
EOF

# ---------- Root files ----------
cat > "$ROOT/package.json" <<'EOF'
{
  "name": "snaplytics-root",
  "private": true,
  "scripts": {
    "install:all": "npm install --prefix backend && npm install --prefix frontend",
    "start:dev": "concurrently \"npm run dev --prefix backend\" \"npm start --prefix frontend\""
  },
  "devDependencies": {
    "concurrently": "^8.2.0"
  }
}
EOF

cat > "$ROOT/Dockerfile" <<'EOF'
# Build frontend
FROM node:18 AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Backend image
FROM node:18
WORKDIR /app
COPY backend/package*.json ./backend/
RUN cd backend && npm install --production
COPY backend/ ./backend
COPY --from=frontend-build /app/frontend/build ./backend/build

WORKDIR /app/backend
EXPOSE 5000
CMD ["node", "server.js"]
EOF

cat > "$ROOT/docker-compose.yml" <<'EOF'
version: "3.8"
services:
  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - SNAP_CLIENT_ID=${SNAP_CLIENT_ID}
      - SNAP_CLIENT_SECRET=${SNAP_CLIENT_SECRET}
      - SNAP_REDIRECT_URI=${SNAP_REDIRECT_URI}
      - SNAP_AUTH_URL=${SNAP_AUTH_URL}
      - SNAP_TOKEN_URL=${SNAP_TOKEN_URL}
    restart: unless-stopped
EOF

cat > "$ROOT/README.md" <<'EOF'
# Snaplytics - Quick Start

## Overview
Snaplytics analyzes Snapchat posting data and recommends the best hours to post for maximum views. The project includes a React frontend and an Express backend with OAuth skeleton for Snapchat and a CSV upload fallback.

## Local setup
1. Copy backend/.env.example to backend/.env and fill your Snapchat app credentials.
2. Install dependencies:
   cd backend
   npm install
   cd ../frontend
   npm install
3. Build frontend:
   npm run build
4. Start backend:
   cd ../backend
   npm start
5. Open http://localhost:5000

## Docker
Build and run with:

docker-compose up --build

## Notes
- Snapchat API access may be limited; use CSV upload if needed.
- Store tokens securely in a database in production.
EOF

cat > "$ROOT/backend/.env.example" <<'EOF'
PORT=5000

SNAP_CLIENT_ID=your_snap_client_id
SNAP_CLIENT_SECRET=your_snap_client_secret
SNAP_REDIRECT_URI=http://localhost:5000/auth/snapchat/callback
SNAP_AUTH_URL=https://accounts.snapchat.com/accounts/oauth2/auth
SNAP_TOKEN_URL=https://accounts.snapchat.com/accounts/oauth2/token
SNAP_SCOPE=user.display_name
EOF

# ---------- Install dependencies and build (optional, ask user) ----------
echo
echo "Files created under ./$ROOT"
echo
read -p "Do you want the script to install npm packages and build the frontend now? (y/N): " DO_INSTALL
DO_INSTALL=${DO_INSTALL:-N}

if [[ "$DO_INSTALL" =~ ^[Yy]$ ]]; then
  echo "Installing backend dependencies..."
  (cd "$ROOT/backend" && npm install)
  echo "Installing frontend dependencies..."
  (cd "$ROOT/frontend" && npm install)
  echo "Building frontend..."
  (cd "$ROOT/frontend" && npm run build)
  echo "Build complete."
else
  echo "Skipping install/build. You can run 'npm install' and 'npm run build' manually."
fi

# ---------- Create ZIP ----------
echo "Creating ZIP archive $ZIPNAME ..."
rm -f "$ZIPNAME"
zip -r "$ZIPNAME" "$ROOT" > /dev/null
echo "Created $ZIPNAME in current directory."

echo
echo "Next steps:"
echo "1) Copy backend/.env.example to backend/.env and fill SNAP_CLIENT_ID and SNAP_CLIENT_SECRET."
echo "2) If you skipped install/build, run:"
echo "   cd $ROOT/backend && npm install"
echo "   cd ../frontend && npm install && npm run build"
echo "3) Start backend: cd $ROOT/backend && npm start"
echo "4) Open http://localhost:5000"
echo
echo "If you want, run: docker-compose up --build (requires Docker)."
