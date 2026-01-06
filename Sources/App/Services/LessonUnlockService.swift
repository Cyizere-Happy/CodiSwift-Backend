import Vapor
import Fluent

final class LessonUnlockService {
    let db: Database
    
    init(db: Database) {
        self.db = db
    }
    
    func unlockNextLesson(for user: User, currentLessonId: UUID) async throws {
        // Find current lesson to get its order index
        guard let currentLesson = try await Lesson.find(currentLessonId, on: db) else {
            return
        }
        
        // Find the next lesson
        let nextOrderIndex = currentLesson.orderIndex + 1
        
        // Find if next lesson exists
        guard let nextLesson = try await Lesson.query(on: db)
            .filter(\.$orderIndex == nextOrderIndex)
            .first() else {
            // No next lesson (End of course)
            return 
        }
        
        // Check if already unlocked
        let existing = try await UserLesson.query(on: db)
            .filter(\.$user.$id == user.id!)
            .filter(\.$lesson.$id == nextLesson.id!)
            .first()
            
        if existing == nil {
            // Create a new progress record for the next lesson (unlocked but not completed)
            let unlock = UserLesson(
                userId: user.id!, 
                lessonId: nextLesson.id!, 
                isCompleted: false,
                quizScore: 0
            )
            try await unlock.save(on: db)
        }
    }
    
    // Check if a user has access to a lesson
    func canAccess(lessonId: UUID, userId: UUID) async throws -> Bool {
        guard let lesson = try await Lesson.find(lessonId, on: db) else { return false }
        
        // First lesson is always accessible
        if lesson.orderIndex == 0 || lesson.orderIndex == 1 { return true }
        
        // Check if previous lesson is completed
        guard let prevLesson = try await Lesson.query(on: db)
            .filter(\.$orderIndex == lesson.orderIndex - 1)
            .first() else {
            return true // Should shouldn't happen if indices are continuous
        }
        
        let prevProgress = try await UserLesson.query(on: db)
            .filter(\.$user.$id == userId)
            .filter(\.$lesson.$id == prevLesson.id!)
            .first()
            
        return prevProgress?.isCompleted ?? false
    }
}
