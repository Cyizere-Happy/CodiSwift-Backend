import Vapor
import JWT

struct UserAuthenticator: AsyncJWTAuthenticator {
    typealias Payload = UserPayload

    func authenticate(jwt: UserPayload, for request: Request) async throws {
        request.auth.login(jwt)
        // Optionally verify user exists in DB if strict strictness is required
        // if let user = try await User.find(...) { request.auth.login(user) }
        // For JWT statelessness, we usually trust the signature and expiration.
        // But to pass "User" object to handlers, we might want to fetch it.
    }
}

// Modify UserPayload to conform to Authenticatable if needed, 
// OR simpler: Authenticate by fetching User.

struct UserTokenAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        // Verify JWT
        let payload = try request.jwt.verify(bearer.token, as: UserPayload.self)
        guard let userID = UUID(uuidString: payload.subject.value),
              let user = try await User.find(userID, on: request.db) else {
            return
        }
        request.auth.login(user)
    }
}
