import Fluent

struct CreateStreak: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("streaks")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("current_streak", .int, .required)
            .field("longest_streak", .int, .required)
            .field("last_played", .datetime, .required)
            .unique(on: "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("streaks").delete()
    }
}
