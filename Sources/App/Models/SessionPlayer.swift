import Fluent
import Vapor

final class SessionPlayer: Model, Content {
    static let schema = "session_players"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "session_id")
    var session: GameSession

    @Parent(key: "user_id")
    var user: User

    @Field(key: "score")
    var score: Int

    init() { }

    init(id: UUID? = nil, sessionId: UUID, userId: UUID, score: Int = 0) {
        self.id = id
        self.$session.id = sessionId
        self.$user.id = userId
        self.score = score
    }
}
