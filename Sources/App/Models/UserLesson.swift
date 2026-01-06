import Fluent
import Vapor

final class UserLesson: Model, Content {
    static let schema = "user_lessons"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "lesson_id")
    var lesson: Lesson

    @Field(key: "is_completed")
    var isCompleted: Bool

    @Field(key: "quiz_score")
    var quizScore: Int

    @Timestamp(key: "completed_at", on: .update)
    var completedAt: Date?

    init() { }

    init(id: UUID? = nil, userId: UUID, lessonId: UUID, isCompleted: Bool = false, quizScore: Int = 0) {
        self.id = id
        self.$user.id = userId
        self.$lesson.id = lessonId
        self.isCompleted = isCompleted
        self.quizScore = quizScore
    }
}
