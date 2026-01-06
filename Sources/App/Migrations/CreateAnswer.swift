import Fluent

struct CreateAnswer: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("answers")
            .id()
            .field("session_id", .uuid, .required, .references("game_sessions", "id", onDelete: .cascade))
            .field("question_id", .uuid, .required, .references("questions", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("selected_index", .int, .required)
            .field("is_correct", .bool, .required)
            .field("answer_time_ms", .int, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("answers").delete()
    }
}
