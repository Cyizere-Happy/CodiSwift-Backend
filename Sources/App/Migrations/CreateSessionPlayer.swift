import Fluent

struct CreateSessionPlayer: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("session_players")
            .id()
            .field("session_id", .uuid, .required, .references("game_sessions", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("score", .int, .required)
            .unique(on: "session_id", "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("session_players").delete()
    }
}
