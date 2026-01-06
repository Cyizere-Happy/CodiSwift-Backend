import Vapor

struct LeaderboardController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let leaderboard = routes.grouped("leaderboard")
        leaderboard.get("global", use: getGlobal)
    }

    func getGlobal(req: Request) async throws -> [Leaderboard] {
        let service = LeaderboardService(db: req.db)
        return try await service.getGlobalLeaderboard()
    }
}
