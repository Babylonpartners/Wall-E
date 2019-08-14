import Bot
import Vapor

enum ConfigurationError: Error {
    case missingConfiguration(message: String)
}

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    let logger = PrintLogger()
    let gitHubEventsService = GitHubEventsService(signatureToken: try Environment.gitHubWebhookSecret())

    logger.log("👟 Starting up...")

    services.register(try makeMergeService(with: logger, gitHubEventsService))

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router, logger: logger, gitHubEventsService: gitHubEventsService)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    logger.log("🏁 Ready")
}

private func makeMergeService(with logger: LoggerProtocol, _ gitHubEventsService: GitHubEventsService) throws -> MergeService {

    let gitHubAPI = GitHubClient(session: URLSession(configuration: .default), token: try Environment.gitHubToken())
        .api(for: Repository(owner: try Environment.gitHubOrganization(), name: try Environment.gitHubRepository()))

    return MergeService(
        integrationLabel: try Environment.mergeLabel(),
        logger: logger,
        gitHubAPI: gitHubAPI,
        gitHubEvents: gitHubEventsService
    )
}

extension Environment {

    static func gitHubWebhookSecret() throws -> String {
        return try Environment.get("GITHUB_WEBHOOK_SECRET")
    }

    static func gitHubToken() throws -> String {
        return try Environment.get("GITHUB_TOKEN")
    }

    static func gitHubOrganization() throws -> String {
        return try Environment.get("GITHUB_ORGANIZATION")
    }

    static func gitHubRepository() throws -> String {
        return try Environment.get("GITHUB_REPOSITORY")
    }

    static func mergeLabel() throws -> PullRequest.Label {
        return PullRequest.Label(name: try Environment.get("MERGE_LABEL"))
    }

    static func get(_ key: String) throws -> String {
        guard let value = Environment.get(key) as String?
            else { throw ConfigurationError.missingConfiguration(message: "💥 key `\(key)` not found in environment") }

        return value
    }
}

extension MergeService: Service {}
