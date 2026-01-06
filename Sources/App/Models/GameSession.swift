import Fluent
import Vapor

enum SessionStatus: String, Codable {
    case waiting
    case active
    case finished
}

final class GameSession: Model, Content {
    static let schema = "game_sessions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "host_id")
    var host: User

    @Field(key: "session_code")
    var sessionCode: String

    @Field(key: "status")
    var status: SessionStatus

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Children(for: \.$session)
    var players: [SessionPlayer]

    init() { }

    init(id: UUID? = nil, hostId: UUID, sessionCode: String, status: SessionStatus = .waiting) {
        self.id = id
        self.$host.id = hostId
        self.sessionCode = sessionCode
        self.status = status
    }
}
