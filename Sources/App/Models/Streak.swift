import Fluent
import Vapor

final class Streak: Model, Content {
    static let schema = "streaks"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "current_streak")
    var currentStreak: Int

    @Field(key: "longest_streak")
    var longestStreak: Int

    @Field(key: "last_played")
    var lastPlayed: Date

    init() { }

    init(id: UUID? = nil, userId: UUID, currentStreak: Int = 0, longestStreak: Int = 0, lastPlayed: Date = Date()) {
        self.id = id
        self.$user.id = userId
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastPlayed = lastPlayed
    }
}
