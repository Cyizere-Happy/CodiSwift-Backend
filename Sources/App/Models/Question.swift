import Fluent
import Vapor

final class Question: Model, Content {
    static let schema = "questions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "lesson_id")
    var lesson: Lesson

    @Field(key: "question_text")
    var questionText: String

    @Field(key: "options")
    var options: [String] // Stored as array

    @Field(key: "correct_index")
    var correctIndex: Int

    @Field(key: "points")
    var points: Int

    @Field(key: "time_limit")
    var timeLimit: Int // seconds

    init() { }

    init(id: UUID? = nil, lessonId: UUID, questionText: String, options: [String], correctIndex: Int, points: Int, timeLimit: Int) {
        self.id = id
        self.$lesson.id = lessonId
        self.questionText = questionText
        self.options = options
        self.correctIndex = correctIndex
        self.points = points
        self.timeLimit = timeLimit
    }
}
