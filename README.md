# CodiSwift Backend

A production-ready Vapor (Swift) backend for the CodiSwift mobile application.

## 🚀 Features

- **Authentication**: JWT-based auth with User/Admin roles.
- **Database**: PostgreSQL with Fluent ORM.
- **Game Engine**: Real-time Kahoot-style quiz sessions using WebSockets.
- **Education**: Lesson unlocking system, interactive Spline scene management.
- **Gamification**: Streaks, Bets, and Global Leaderboards.

## 🛠 Prerequisites

- Swift 5.9+
- PostgreSQL
- Vapor Toolbox (optional)

## 📦 Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your/repo.git
    cd CodiSwift-Backend
    ```

2.  **Configure Environment:**
    Set the `DATABASE_URL` environment variable or update `configure.swift` with your PostgreSQL credentials.
    ```bash
    export DATABASE_URL="postgres://username:password@localhost:5432/codiswift_db"
    export JWT_SECRET="super-secret-key"
    ```

3.  **Run Migrations:**
    ```bash
    swift run App migrate
    ```

4.  **Start the Server:**
    ```bash
    swift run App
    ```
    The server will start at `http://127.0.0.1:8080`.

## 📚 API Overview

### Public
- `POST /auth/register` - Create account
- `POST /auth/login` - Get JWT token

### Authenticated (Bearer Token required)
- `GET /users/me` - Get profile
- `GET /lessons` - List lessons
- `POST /lessons/:id/complete` - Complete lesson & unlock next
- `POST /sessions/create` - Host a game
- `POST /sessions/join` - Join a game

### Admin Only
- `POST /lessons` - Create lesson
- `POST /lessons/:id/questions` - Add questions

### Real-time
- `WS /sessions/:id/socket?token=...` - Connect to game session

## 🏗 Project Structure

- `Sources/App/Controllers`: REST API Handlers
- `Sources/App/Models`: Database Models
- `Sources/App/Services`: Business Logic (Auth, Game, Scoring)
- `Sources/App/WebSockets`: WebSocket Manager

## 🧪 Testing

Run tests with:
```bash
swift test
```
