import Vapor
import Fluent

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
    }

    func register(req: Request) async throws -> String {
        let content = try req.content.decode(RegisterRequest.self)
        
        // Validation (basic)
        if try await User.query(on: req.db).filter(\.$username == content.username).first() != nil {
            throw Abort(.conflict, reason: "Username already exists")
        }
        
        let passwordHash = try req.password.hash(content.password)
        let user = User(username: content.username, email: content.email, passwordHash: passwordHash)
        try await user.save(on: req.db)
        
        // Initialize stats
        let streak = Streak(userId: user.id!)
        try await streak.save(on: req.db)
        
        let leaderboard = Leaderboard(userId: user.id!, totalPoints: 0, rank: 0)
        try await leaderboard.save(on: req.db)

        return "User registered successfully"
    }

    func login(req: Request) async throws -> LoginResponse {
        let content = try req.content.decode(LoginRequest.self)
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == content.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        if try !req.password.verify(content.password, created: user.passwordHash) {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        let authService = AuthService(app: req.application)
        let token = try authService.generateToken(for: user)
        
        return LoginResponse(token: token, user: user)
    }
}

// DTOs
struct RegisterRequest: Content {
    var username: String
    var email: String
    var password: String
}

struct LoginRequest: Content {
    var email: String
    var password: String
}

struct LoginResponse: Content {
    var token: String
    var user: User
}
