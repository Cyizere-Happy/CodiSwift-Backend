import Vapor
import JWT

struct AdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Ensure user is authenticated first (AuthMiddleware should run before this)
        // Check payload for admin role
        let payload = try request.jwt.verify(as: UserPayload.self)
        
        guard payload.isAdmin else {
            throw Abort(.forbidden, reason: "Admin access required")
        }
        
        return try await next.respond(to: request)
    }
}
