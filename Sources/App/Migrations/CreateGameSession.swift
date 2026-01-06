import Fluent

struct CreateGameSession: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("game_sessions")
            .id()
            .field("host_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("session_code", .string, .required)
            .field("status", .string, .required)
            .field("created_at", .datetime)
            .unique(on: "session_code")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("game_sessions").delete()
    }
}
