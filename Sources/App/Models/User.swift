import Fluent
import Vapor

enum UserRole: String, Codable {
    case admin
    case user
}

final class User: Model, Content, ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Field(key: "role")
    var role: UserRole

    @Field(key: "total_points")
    var totalPoints: Int

    @Field(key: "rank")
    var rank: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, username: String, email: String, passwordHash: String, role: UserRole = .user, totalPoints: Int = 0, rank: Int = 0) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
        self.totalPoints = totalPoints
        self.rank = rank
    }
}
