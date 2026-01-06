import Fluent

struct CreateLesson: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("lessons")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("educational_content", .string, .required) // Consider changing to .text (large text) if supported by specific driver implementation, but .string usually works for Fluent
            .field("example_code", .string, .required)
            .field("spline_scene_url", .string, .required)
            .field("difficulty", .string, .required)
            .field("order_index", .int, .required)
            .field("is_locked", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("lessons").delete()
    }
}
