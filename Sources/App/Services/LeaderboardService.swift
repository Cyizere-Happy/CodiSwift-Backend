import Vapor
import Fluent

final class LeaderboardService {
    let db: Database
    
    init(db: Database) {
        self.db = db
    }
    
    func updateScore(for userId: UUID, points: Int) async throws {
        // Update User total points
        guard let user = try await User.find(userId, on: db) else { return }
        user.totalPoints += points
        try await user.save(on: db)
        
        // Update Leaderboard entry
        let entry = try await Leaderboard.query(on: db)
            .filter(\.$user.$id == userId)
            .first() ?? Leaderboard(userId: userId, totalPoints: 0, rank: 0)
            
        entry.totalPoints = user.totalPoints
        try await entry.save(on: db)
        
        // NOTE: Rank recalculation is expensive to do here for every update.
        // A production app would use Redis or a scheduled job.
        // For this task, we will calculate ranks dynamically on retrieval or leave it for a background job.
    }
    
    func getGlobalLeaderboard(limit: Int = 100) async throws -> [Leaderboard] {
        // Fetch top users sorted by points
        // If we want to return `Leaderboard` models, we ensure they are up to date.
        return try await Leaderboard.query(on: db)
            .sort(\.$totalPoints, .descending)
            .with(\.$user) // Create Relation to return username easily
            .limit(limit)
            .all()
    }
}
