const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send(`
    <h1>Snaplytics</h1>
    <p>التطبيق شغال</p>
    <a href="/dashboard">اذهب إلى Dashboard</a>
  `);
});

app.get("/dashboard", (req, res) => {
  res.send(`
    <h2>أفضل وقت للنشر</h2>
    <p>اليوم الساعة 8:00 مساءً</p>
    <p>توقع المشاهدات: 5200</p>
  `);
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log("Snaplytics running on port " + PORT);
});
