import Vapor
import Fluent

struct LessonController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let lessons = routes.grouped("lessons")
        
        // Public/Authenticated User Routes
        lessons.get(use: index)
        lessons.get(":lessonID", use: get)
        lessons.get(":lessonID", "questions", use: getQuestions)
        lessons.post(":lessonID", "complete", use: complete)
        
        // Admin Routes
        let admin = lessons.grouped(AdminMiddleware())
        admin.post(use: create)
        admin.delete(":lessonID", use: delete)
        admin.post(":lessonID", "questions", use: addQuestion)
    }

    // LIST /lessons
    func index(req: Request) async throws -> [Lesson] {
        // Return only unlocked lessons for the user? Or all, and frontend shows lock?
        // Prompt says "Prevent access to locked". 
        // For list, we probably want to see *all* so we can see the path.
        // We will sort by orderIndex.
        return try await Lesson.query(on: req.db).sort(\.$orderIndex).all()
    }

    // POST /lessons (Admin)
    func create(req: Request) async throws -> Lesson {
        let lesson = try req.content.decode(Lesson.self)
        try await lesson.save(on: req.db)
        return lesson
    }

    // GET /lessons/:id
    func get(req: Request) async throws -> Lesson {
        guard let lesson = try await Lesson.find(req.parameters.get("lessonID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return lesson
    }
    
    // DELETE /lessons/:id (Admin)
    func delete(req: Request) async throws -> HTTPStatus {
        guard let lesson = try await Lesson.find(req.parameters.get("lessonID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await lesson.delete(on: req.db)
        return .noContent
    }

    // POST /lessons/:id/questions (Admin)
    func addQuestion(req: Request) async throws -> Question {
        let question = try req.content.decode(Question.self)
        // Ensure lesson exists
        guard let lessonID = req.parameters.get("lessonID", as: UUID.self) else { throw Abort(.badRequest) }
        question.$lesson.id = lessonID
        try await question.save(on: req.db)
        return question
    }

    // GET /lessons/:id/questions
    func getQuestions(req: Request) async throws -> [Question] {
        guard let lessonID = req.parameters.get("lessonID", as: UUID.self) else { throw Abort(.badRequest) }
        return try await Question.query(on: req.db)
            .filter(\.$lesson.$id == lessonID)
            .all()
    }

    // POST /lessons/:id/complete
    func complete(req: Request) async throws -> HTTPStatus {
        guard let lessonID = req.parameters.get("lessonID", as: UUID.self) else { throw Abort(.badRequest) }
        
        let payload = try req.jwt.verify(as: UserPayload.self)
        guard let userID = UUID(uuidString: payload.subject.value),
              let user = try await User.find(userID, on: req.db) else {
            throw Abort(.unauthorized)
        }
        
        // Mark as completed
        if let existing = try await UserLesson.query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$lesson.$id == lessonID)
            .first() {
            existing.isCompleted = true
            existing.completedAt = Date()
            try await existing.save(on: req.db)
        } else {
            let progress = UserLesson(userId: userID, lessonId: lessonID, isCompleted: true)
            progress.completedAt = Date()
            try await progress.save(on: req.db)
        }
        
        // Unlock next
        let unlockService = LessonUnlockService(db: req.db)
        try await unlockService.unlockNextLesson(for: user, currentLessonId: lessonID)
        
        return .ok
    }
}
