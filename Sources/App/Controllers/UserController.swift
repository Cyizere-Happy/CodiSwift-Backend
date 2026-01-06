import Vapor
import Fluent
import JWT

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        // Protected routes
        // Note: Middleware needed in configure.swift or here using grouped
        // Assuming we apply auth middleware globally or per group in routes.swift
        // Here we just define handlers.
        
        users.get("me", use: getProfile)
    }

    func getProfile(req: Request) async throws -> User {
        return try req.auth.require(User.self)
    }
}
