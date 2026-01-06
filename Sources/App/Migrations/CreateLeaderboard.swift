import Fluent

struct CreateLeaderboard: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("leaderboard")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("total_points", .int, .required)
            .field("rank", .int, .required)
            .unique(on: "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("leaderboard").delete()
    }
}
