# Snaplytics

## Overview
Snaplytics is a Node.js/TypeScript Express web application with Replit Auth. It provides a dashboard with social media posting time recommendations and view predictions.

## Project Architecture
- **Runtime**: Node.js 20 with TypeScript (tsx)
- **Framework**: Express 4.x
- **Database**: PostgreSQL with Drizzle ORM
- **Authentication**: Replit Auth (OpenID Connect)
- **Entry point**: `server/index.ts`
- **Port**: 5000 (bound to 0.0.0.0)

## Project Structure
```
server/
  index.ts                          - Main Express server with routes
  db.ts                             - Database connection (Drizzle + pg)
  replit_integrations/auth/         - Replit Auth integration module
    index.ts                        - Auth exports
    replitAuth.ts                   - OIDC passport setup
    storage.ts                      - User DB operations
    routes.ts                       - Auth API routes
shared/
  schema.ts                         - Drizzle schema exports
  models/
    auth.ts                         - Users and sessions table schemas
```

## Routes
- `/` - Landing page (logged out) or welcome page (logged in)
- `/dashboard` - Protected dashboard with posting recommendations
- `/api/login` - Begin login flow
- `/api/logout` - Logout
- `/api/auth/user` - Get current user
- `/api/callback` - OIDC callback

## Database
- `users` - Stores authenticated user profiles
- `sessions` - Stores session data

## Running
The app starts via `npx tsx server/index.ts` and listens on port 5000.
Use `npm run db:push` to push schema changes.
