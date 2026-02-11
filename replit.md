# Snaplytics

## Overview
Snaplytics is a Node.js Express web application. It provides a simple dashboard with posting time recommendations and view predictions.

## Project Architecture
- **Runtime**: Node.js 20
- **Framework**: Express 4.x
- **Entry point**: `backend/index.js`
- **Port**: 5000 (bound to 0.0.0.0)

## Project Structure
```
backend/
  index.js        - Express server with routes (/, /dashboard)
package.json      - Dependencies and scripts
```

## Routes
- `/` - Home page
- `/dashboard` - Dashboard with posting recommendations

## Running
The app starts via `node backend/index.js` and listens on port 5000.
