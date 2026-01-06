import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Database Configuration
    // Database Configuration
    guard let databaseURL = Environment.get("DATABASE_URL") else {
        fatalError("No DATABASE_URL found in environment variables")
    }
    try app.databases.use(.postgres(url: databaseURL), as: .psql)

    // JWT Configuration
    guard let jwtSecret = Environment.get("JWT_SECRET") else {
        fatalError("No JWT_SECRET found in environment variables")
    }
    app.jwt.signers.use(.hs256(key: jwtSecret))


    // Migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateLesson())
    app.migrations.add(CreateQuestion())
    app.migrations.add(CreateUserLesson())
    app.migrations.add(CreateGameSession())
    app.migrations.add(CreateSessionPlayer())
    app.migrations.add(CreateAnswer())
    app.migrations.add(CreateBet())
    app.migrations.add(CreateStreak())
    app.migrations.add(CreateLeaderboard())

    // register routes
    try routes(app)
}
