import Fluent

struct CreateBet: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("bets")
            .id()
            .field("session_id", .uuid, .required, .references("game_sessions", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("bet_points", .int, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("bets").delete()
    }
}
