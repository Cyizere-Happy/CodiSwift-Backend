import Fluent

struct CreateQuestion: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("questions")
            .id()
            .field("lesson_id", .uuid, .required, .references("lessons", "id", onDelete: .cascade))
            .field("question_text", .string, .required)
            .field("options", .array(of: .string), .required)
            .field("correct_index", .int, .required)
            .field("points", .int, .required)
            .field("time_limit", .int, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("questions").delete()
    }
}
