import Vapor

final class ScoringService {
    // Base points for a correct answer
    static let basePoints = 1000
    
    // Calculate score based on correctness and time elapsed
    // timeLimit and answerTimeMs are in appropriate units (seconds and milliseconds)
    func calculateScore(isCorrect: Bool, timeLimitSeconds: Int, answerTimeMs: Int) -> Int {
        guard isCorrect else { return 0 }
        
        // Kahoot-style scoring logic:
        // Score = (1 - (response time / question time) / 2) * 1000
        // Or simpler linear decay
        
        let timeLimitMs = Double(timeLimitSeconds * 1000)
        let responseTime = Double(answerTimeMs)
        
        // Ensure we don't divide by zero or have negative time
        if timeLimitMs <= 0 { return ScoringService.basePoints }
        
        // If answered instantly (impossible but theoretically), full points.
        // If answered at last second, half points (500).
        let ratio = responseTime / timeLimitMs
        let score = Double(ScoringService.basePoints) * (1.0 - (ratio / 2.0))
        
        return Int(max(score, 0))
    }
}
