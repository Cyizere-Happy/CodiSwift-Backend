import Vapor

class GameSocketManager {
    static let shared = GameSocketManager()
    
    // sessionID -> [userID: WebSocket]
    var sessions: [UUID: [UUID: WebSocket]] = [:]
    
    private init() {}
    
    func add(player: User, sessionID: UUID, socket: WebSocket) {
        if sessions[sessionID] == nil {
            sessions[sessionID] = [:]
        }
        sessions[sessionID]?[player.id!] = socket
        
        // Notify others
        broadcast(to: sessionID, message: "Player \(player.username) joined", type: "playerJoined")
    }
    
    func remove(playerID: UUID, sessionID: UUID) {
        sessions[sessionID]?[playerID] = nil
        if sessions[sessionID]?.isEmpty == true {
            sessions[sessionID] = nil
        }
    }
    
    func broadcast(to sessionID: UUID, message: String, type: String) {
        guard let connections = sessions[sessionID] else { return }
        
        let payload = ["type": type, "message": message]
        // JSON encoding
        if let data = try? JSONEncoder().encode(payload),
           let text = String(data: data, encoding: .utf8) {
            for (_, socket) in connections {
                socket.send(text)
            }
        }
    }
    
    func sendQuestion(to sessionID: UUID, question: Question) {
        // Obscure correct answer before sending!
        let safeQuestion = ["id": question.id!.uuidString, "text": question.questionText, "options": question.options] as [String : Any]
        // In a real implementation we would define a Codable struct for this event
        // For now, basic JSON serialization is handled inside broadcast or here.
        // Since `broadcast` takes a String, we should serialize here.
        if let data = try? JSONSerialization.data(withJSONObject: safeQuestion),
           let jsonString = String(data: data, encoding: .utf8) {
            broadcast(to: sessionID, message: jsonString, type: "nextQuestion")
        }
    }
    
    func handleMessage(sessionID: UUID, playerID: UUID, text: String) {
        // Parse the incoming text message
        // Example: {"type": "answer", "questionID": "...", "index": 2}
        
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            return
        }
        
        switch type {
        case "answer":
            // Process answer (would call GameService.submitAnswer)
            // Note: Since this is synchronous, we'd need to spawn a Task to call async DB/Service methods
            Task {
                // Logic to handle answer submission
                // await gameService.submitAnswer(...)
            }
        default:
            break
        }
    }
}
