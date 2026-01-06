import Fluent
import Vapor

final class Bet: Model, Content {
    static let schema = "bets"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "session_id")
    var session: GameSession

    @Parent(key: "user_id")
    var user: User

    @Field(key: "bet_points")
    var betPoints: Int

    init() { }

    init(id: UUID? = nil, sessionId: UUID, userId: UUID, betPoints: Int) {
        self.id = id
        self.$session.id = sessionId
        self.$user.id = userId
        self.betPoints = betPoints
    }
}
