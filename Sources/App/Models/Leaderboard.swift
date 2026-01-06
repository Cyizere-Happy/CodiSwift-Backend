import Fluent
import Vapor

final class Leaderboard: Model, Content {
    static let schema = "leaderboard"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "total_points")
    var totalPoints: Int

    @Field(key: "rank")
    var rank: Int

    init() { }

    init(id: UUID? = nil, userId: UUID, totalPoints: Int, rank: Int) {
        self.id = id
        self.$user.id = userId
        self.totalPoints = totalPoints
        self.rank = rank
    }
}
