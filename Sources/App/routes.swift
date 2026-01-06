import Vapor
import Fluent

func routes(_ app: Application) throws {
    app.get { req async in
        "CodiSwift Backend is running!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // Register Controllers
    try app.register(collection: AuthController())
    try app.register(collection: UserController())
    try app.register(collection: LessonController())
    try app.register(collection: SessionController())
    try app.register(collection: LeaderboardController())

    // WebSocket Route
    app.webSocket("sessions", ":sessionID", "socket") { req, ws in
        guard let sessionID = req.parameters.get("sessionID", as: UUID.self) else {
            ws.close(promise: nil)
            return
        }
        
        // Simple auth via query param since WS doesn't support headers effectively in all clients
        // Or handle initial message for auth. For simplicity here:
        // In production, validate token from query param ?token=...
        
        // Authentication
        guard let token = req.query[String.self, at: "token"] else {
            ws.close(code: .policyViolation)
            return
        }

        do {
            let payload = try req.jwt.verify(token, as: UserPayload.self)
            guard let userID = UUID(uuidString: payload.subject.value) else {
                ws.close(code: .policyViolation)
                return
            }

            // Ideally, check if user exists in DB, but for performance we might trust the signed JWT 
            // or do a quick lookup. Since this is a closure, we need to be careful with async.
            // Vapor 4 WebSocket API is callback-based. 
            
            // We'll perform a quick check by looking up the user in a Task
            Task {
                do {
                    if let user = try await User.find(userID, on: req.db) {
                        GameSocketManager.shared.add(player: user, sessionID: sessionID, socket: ws)
                        
                        ws.onClose.whenComplete { _ in
                            GameSocketManager.shared.remove(playerID: user.id!, sessionID: sessionID)
                        }
                        
                        ws.onText { ws, text in
                            // Handle incoming messages
                            // GameSocketManager.shared.handleMessage(sessionID: sessionID, playerID: userID, text: text)
                        }
                        
                        // Send welcome
                        ws.send("Connected to session \(sessionID)")
                    } else {
                        try await ws.close(code: .policyViolation)
                    }
                } catch {
                    try? await ws.close(code: .unexpectedServerError)
                }
            }
        } catch {
            ws.close(code: .policyViolation)
        }
    }
}
