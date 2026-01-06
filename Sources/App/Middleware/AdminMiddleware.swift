import Vapor
import JWT

struct AdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Ensure user is authenticated first (AuthMiddleware should run before this)
        let user = try request.auth.require(User.self)
        
        guard user.role == .admin else {
            throw Abort(.forbidden, reason: "Admin access required")
        }
        
        return try await next.respond(to: request)
    }
}
