import Vapor
import Fluent

struct SessionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sessions = routes.grouped("sessions")
        sessions.post("create", use: create)
        sessions.post("join", use: join)
    }

    func create(req: Request) async throws -> GameSession {
        let payload = try req.jwt.verify(as: UserPayload.self)
        guard let userID = UUID(uuidString: payload.subject.value) else {
            throw Abort(.unauthorized)
        }
        
        // Generate random code
        let code = String(Int.random(in: 100000...999999))
        
        let gameService = GameService(db: req.db)
        return try await gameService.createSession(hostId: userID, sessionCode: code)
    }

    func join(req: Request) async throws -> GameSession {
        let payload = try req.jwt.verify(as: UserPayload.self)
        guard let userID = UUID(uuidString: payload.subject.value) else {
            throw Abort(.unauthorized)
        }
        
        struct JoinRequest: Content {
            var sessionCode: String
        }
        let content = try req.content.decode(JoinRequest.self)
        
        let gameService = GameService(db: req.db)
        return try await gameService.joinSession(sessionCode: content.sessionCode, userId: userID)
    }
}
