import Fluent
import Vapor

enum Difficulty: String, Codable {
    case beginner
    case intermediate
    case advanced
}

final class Lesson: Model, Content {
    static let schema = "lessons"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "educational_content")
    var educationalContent: String // Markdown or text

    @Field(key: "example_code")
    var exampleCode: String // Swift code snippet

    @Field(key: "spline_scene_url")
    var splineSceneUrl: String

    @Field(key: "difficulty")
    var difficulty: Difficulty

    @Field(key: "order_index")
    var orderIndex: Int

    @Field(key: "is_locked")
    var isLocked: Bool

    @Children(for: \.$lesson)
    var questions: [Question]

    init() { }

    init(id: UUID? = nil, title: String, description: String, educationalContent: String, exampleCode: String, splineSceneUrl: String, difficulty: Difficulty, orderIndex: Int, isLocked: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.educationalContent = educationalContent
        self.exampleCode = exampleCode
        self.splineSceneUrl = splineSceneUrl
        self.difficulty = difficulty
        self.orderIndex = orderIndex
        self.isLocked = isLocked
    }
}
