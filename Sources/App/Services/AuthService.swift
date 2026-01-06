import Vapor
import Fluent
import JWT

struct UserPayload: JWTPayload {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var isAdmin: Bool

    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case isAdmin = "admin"
    }

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

final class AuthService {
    let app: Application

    init(app: Application) {
        self.app = app
    }

    func generateToken(for user: User) throws -> String {
        let payload = UserPayload(
            subject: .init(value: user.id!.uuidString),
            expiration: .init(value: .init(timeIntervalSinceNow: 60 * 60 * 24)), // 24 hours
            isAdmin: user.role == .admin
        )
        return try app.jwt.signers.sign(payload)
    }
}
