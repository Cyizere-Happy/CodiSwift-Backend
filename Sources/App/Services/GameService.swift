import Vapor
import Fluent

// Actor to manage game state safely across async contexts
actor GameService {
    // In-memory storage for active sessions logic if needed, 
    // but we primarily rely on DB for this app as per constraints.
    // However, for real-time validation, we might keep some state here.
    
    let db: Database
    let scoringService: ScoringService
    
    init(db: Database) {
        self.db = db
        self.scoringService = ScoringService()
    }
    
    func createSession(hostId: UUID, sessionCode: String) async throws -> GameSession {
        // Implement session creation logic
        let session = GameSession(hostId: hostId, sessionCode: sessionCode, status: .waiting)
        try await session.save(on: db)
        return session
    }
    
    func joinSession(sessionCode: String, userId: UUID) async throws -> GameSession {
        guard let session = try await GameSession.query(on: db)
            .filter(\.$sessionCode == sessionCode)
            .filter(\.$status == .waiting)
            .first() else {
            throw Abort(.notFound, reason: "Session not found or not waiting")
        }
        
        // Check if already joined
        let existing = try await SessionPlayer.query(on: db)
            .filter(\.$session.$id == session.id!)
            .filter(\.$user.$id == userId)
            .first()
            
        if existing == nil {
            let player = SessionPlayer(sessionId: session.id!, userId: userId)
            try await player.save(on: db)
        }
        
        return session
    }
    
    func submitAnswer(sessionId: UUID, userId: UUID, questionId: UUID, selectedIndex: Int, timeElapsedMs: Int) async throws -> Int {
        guard let question = try await Question.find(questionId, on: db) else {
            throw Abort(.notFound)
        }
        
        let isCorrect = (selectedIndex == question.correctIndex)
        let points = scoringService.calculateScore(
            isCorrect: isCorrect,
            timeLimitSeconds: question.timeLimit,
            answerTimeMs: timeElapsedMs
        )
        
        // Save Answer
        let answer = Answer(
            sessionId: sessionId,
            questionId: questionId,
            userId: userId,
            selectedIndex: selectedIndex,
            isCorrect: isCorrect,
            answerTimeMs: timeElapsedMs
        )
        try await answer.save(on: db)
        
        // Update Player Score
        if let player = try await SessionPlayer.query(on: db)
            .filter(\.$session.$id == sessionId)
            .filter(\.$user.$id == userId)
            .first() {
            player.score += points
            try await player.save(on: db)
        }
        
        return points
    }
}
