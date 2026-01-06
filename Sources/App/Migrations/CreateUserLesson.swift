import Fluent

struct CreateUserLesson: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_lessons")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("lesson_id", .uuid, .required, .references("lessons", "id", onDelete: .cascade))
            .field("is_completed", .bool, .required)
            .field("quiz_score", .int, .required)
            .field("completed_at", .datetime)
            .unique(on: "user_id", "lesson_id") // One record per lesson per user
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_lessons").delete()
    }
}
