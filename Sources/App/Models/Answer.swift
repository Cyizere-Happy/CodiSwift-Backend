import Fluent
import Vapor

final class Answer: Model, Content {
    static let schema = "answers"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "session_id")
    var session: GameSession

    @Parent(key: "question_id")
    var question: Question

    @Parent(key: "user_id")
    var user: User

    @Field(key: "selected_index")
    var selectedIndex: Int

    @Field(key: "is_correct")
    var isCorrect: Bool

    @Field(key: "answer_time_ms")
    var answerTimeMs: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, sessionId: UUID, questionId: UUID, userId: UUID, selectedIndex: Int, isCorrect: Bool, answerTimeMs: Int) {
        self.id = id
        self.$session.id = sessionId
        self.$question.id = questionId
        self.$user.id = userId
        self.selectedIndex = selectedIndex
        self.isCorrect = isCorrect
        self.answerTimeMs = answerTimeMs
    }
}
