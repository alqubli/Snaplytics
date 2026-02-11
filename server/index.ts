import express from "express";
import { setupAuth, registerAuthRoutes, isAuthenticated } from "./replit_integrations/auth";

const app = express();

async function main() {
  await setupAuth(app);
  registerAuthRoutes(app);

  app.get("/", (req: any, res) => {
    const user = req.user;
    if (user && user.claims) {
      const name = user.claims.first_name || user.claims.email || "User";
      const profileImg = user.claims.profile_image_url;
      res.send(`
        <!DOCTYPE html>
        <html lang="ar" dir="rtl">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Snaplytics</title>
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; color: #333; }
            .header { background: rgba(255,255,255,0.95); padding: 16px 32px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header h1 { font-size: 24px; color: #667eea; }
            .user-info { display: flex; align-items: center; gap: 12px; }
            .user-info img { width: 36px; height: 36px; border-radius: 50%; }
            .user-info span { font-weight: 500; }
            .logout-btn { background: #e74c3c; color: white; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; text-decoration: none; font-size: 14px; }
            .logout-btn:hover { background: #c0392b; }
            .container { max-width: 800px; margin: 40px auto; padding: 0 20px; }
            .welcome-card { background: white; border-radius: 16px; padding: 40px; text-align: center; box-shadow: 0 10px 40px rgba(0,0,0,0.1); margin-bottom: 24px; }
            .welcome-card h2 { font-size: 28px; margin-bottom: 12px; color: #333; }
            .welcome-card p { color: #666; font-size: 16px; }
            .nav-card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); text-align: center; }
            .nav-card a { display: inline-block; background: linear-gradient(135deg, #667eea, #764ba2); color: white; padding: 14px 32px; border-radius: 8px; text-decoration: none; font-size: 16px; font-weight: 500; transition: transform 0.2s; }
            .nav-card a:hover { transform: translateY(-2px); }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>Snaplytics</h1>
            <div class="user-info">
              ${profileImg ? `<img src="${profileImg}" alt="Profile">` : ""}
              <span>${name}</span>
              <a href="/api/logout" class="logout-btn">تسجيل خروج</a>
            </div>
          </div>
          <div class="container">
            <div class="welcome-card">
              <h2>مرحباً، ${name}!</h2>
              <p>التطبيق شغال - هدفنا رفع المشاهدات</p>
            </div>
            <div class="nav-card">
              <a href="/dashboard">اذهب إلى Dashboard</a>
            </div>
          </div>
        </body>
        </html>
      `);
    } else {
      res.send(`
        <!DOCTYPE html>
        <html lang="ar" dir="rtl">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Snaplytics</title>
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; min-height: 100vh; display: flex; }
            .left-panel { flex: 1; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 60px; color: white; }
            .left-panel h1 { font-size: 48px; margin-bottom: 16px; font-weight: 700; }
            .left-panel p { font-size: 20px; opacity: 0.9; max-width: 400px; text-align: center; line-height: 1.6; }
            .right-panel { flex: 1; display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 60px; background: #fafbfc; }
            .right-panel h2 { font-size: 28px; margin-bottom: 12px; color: #333; }
            .right-panel p { color: #666; margin-bottom: 32px; font-size: 16px; }
            .login-btn { background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 16px 48px; border-radius: 10px; font-size: 18px; cursor: pointer; text-decoration: none; font-weight: 600; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 15px rgba(102,126,234,0.4); }
            .login-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102,126,234,0.6); }
            @media (max-width: 768px) {
              body { flex-direction: column; }
              .left-panel { padding: 40px 20px; }
              .left-panel h1 { font-size: 32px; }
              .right-panel { padding: 40px 20px; }
            }
          </style>
        </head>
        <body>
          <div class="left-panel">
            <h1>Snaplytics</h1>
            <p>حلل أداء حساباتك على السوشال ميديا وارفع مشاهداتك</p>
          </div>
          <div class="right-panel">
            <h2>مرحباً بك</h2>
            <p>سجل دخولك للبدء</p>
            <a href="/api/login" class="login-btn">تسجيل الدخول</a>
          </div>
        </body>
        </html>
      `);
    }
  });

  app.get("/dashboard", isAuthenticated, (req: any, res) => {
    const name = req.user?.claims?.first_name || "User";
    res.send(`
      <!DOCTYPE html>
      <html lang="ar" dir="rtl">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dashboard - Snaplytics</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f0f2f5; min-height: 100vh; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 16px 32px; display: flex; justify-content: space-between; align-items: center; color: white; }
          .header h1 { font-size: 24px; }
          .header a { color: white; text-decoration: none; opacity: 0.9; }
          .header a:hover { opacity: 1; }
          .container { max-width: 800px; margin: 32px auto; padding: 0 20px; }
          .card { background: white; border-radius: 12px; padding: 28px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); margin-bottom: 20px; }
          .card h2 { color: #333; margin-bottom: 16px; font-size: 22px; }
          .stat { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid #eee; }
          .stat:last-child { border: none; }
          .stat-label { color: #666; }
          .stat-value { font-weight: 700; color: #667eea; font-size: 20px; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Snaplytics Dashboard</h1>
          <a href="/">الرئيسية</a>
        </div>
        <div class="container">
          <div class="card">
            <h2>أفضل وقت للنشر</h2>
            <div class="stat">
              <span class="stat-label">الوقت المثالي</span>
              <span class="stat-value">8:00 مساءً</span>
            </div>
            <div class="stat">
              <span class="stat-label">اليوم الأفضل</span>
              <span class="stat-value">الخميس</span>
            </div>
          </div>
          <div class="card">
            <h2>توقعات المشاهدات</h2>
            <div class="stat">
              <span class="stat-label">التوقع اليوم</span>
              <span class="stat-value">5,200</span>
            </div>
            <div class="stat">
              <span class="stat-label">متوسط الأسبوع</span>
              <span class="stat-value">4,800</span>
            </div>
          </div>
        </div>
      </body>
      </html>
    `);
  });

  const PORT = parseInt(process.env.PORT || "5000", 10);
  app.listen(PORT, "0.0.0.0", () => {
    console.log("Snaplytics running on port " + PORT);
  });
}

main().catch(console.error);
