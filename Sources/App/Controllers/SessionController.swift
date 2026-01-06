import Vapor
import Fluent

struct SessionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sessions = routes.grouped("sessions")
        sessions.post("create", use: create)
        sessions.post("join", use: join)
    }

    func create(req: Request) async throws -> GameSession {
        let user = try req.auth.require(User.self)
        
        // Generate random code
        let code = String(Int.random(in: 100000...999999))
        
        let gameService = GameService(db: req.db)
        return try await gameService.createSession(hostId: user.id!, sessionCode: code)
    }

    func join(req: Request) async throws -> GameSession {
        let user = try req.auth.require(User.self)
        
        struct JoinRequest: Content {
            var sessionCode: String
        }
        let content = try req.content.decode(JoinRequest.self)
        
        let gameService = GameService(db: req.db)
        return try await gameService.joinSession(sessionCode: content.sessionCode, userId: user.id!)
    }
}
