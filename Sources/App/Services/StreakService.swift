import Vapor
import Fluent

final class StreakService {
    let db: Database
    
    init(db: Database) {
        self.db = db
    }
    
    func updateStreak(for userId: UUID) async throws {
        let streak = try await Streak.query(on: db)
            .filter(\.$user.$id == userId)
            .first() ?? Streak(userId: userId)
            
        let calendar = Calendar.current
        
        // Check difference between lastPlayed and today
        if calendar.isDateInToday(streak.lastPlayed) {
            // Already played today, do nothing
            return
        } else if calendar.isDateInYesterday(streak.lastPlayed) {
            // Played yesterday, increment streak
            streak.currentStreak += 1
            if streak.currentStreak > streak.longestStreak {
                streak.longestStreak = streak.currentStreak
            }
        } else {
            // Missed a day (or more), reset streak
            streak.currentStreak = 1
        }
        
        streak.lastPlayed = Date()
        try await streak.save(on: db)
    }
}
