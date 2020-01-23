import Vapor
import Bot

extension Environment {

    /// GitHub Webhook secret
    static func gitHubWebhookSecret() throws -> String {
        return try Environment.get("GITHUB_WEBHOOK_SECRET")
    }

    /// GitHub Token
    static func gitHubToken() throws -> String {
        return try Environment.get("GITHUB_TOKEN")
    }

    /// GitHub Organisation name (as seen in the github.com/<orgname>/* urls)
    static func gitHubOrganization() throws -> String {
        return try Environment.get("GITHUB_ORGANIZATION")
    }

    /// URL of GitHub Repository to run the MergeBot on
    static func gitHubRepository() throws -> String {
        return try Environment.get("GITHUB_REPOSITORY")
    }

    /// If set to YES/1/TRUE, the Merge Bot will require all GitHub status checks to pass before accepting to merge
    /// Otherwise, only the GitHub status checks that are marked as "required" in the GitHub settings to pass
    static func requiresAllGitHubStatusChecks() throws -> Bool {
        guard let stringValue: String = Environment.get("REQUIRES_ALL_STATUS_CHECKS") else {
            return false // defaults to only consider required checks
        }
        return ["yes", "1", "true"].contains(stringValue.lowercased())
    }

    /// Maximum time to wait for a status check to finish running and report a red/green status
    static func statusChecksTimeout() throws -> TimeInterval? {
        let value: String = try Environment.get("STATUS_CHECKS_TIMEOUT")
        return TimeInterval(value)
    }

    /// Delay to wait after a MergeService is back in idle state before killing it. Defaults to 5 minutes.
    static func idleMergeServiceCleanupDelay() throws -> TimeInterval? {
        let value: String? = Environment.get("IDLE_BRANCH_QUEUE_CLEANUP_DELAY")
        return value.flatMap(TimeInterval.init)
    }

    /// The text of the GitHub label that you want to use to trigger the MergeBot and add a PR to the queue
    static func mergeLabel() throws -> PullRequest.Label {
        return PullRequest.Label(name: try Environment.get("MERGE_LABEL"))
    }

    /// Comma-separated list of GitHub label names that you want to use to bump a PR's priority – and make it jump to the front of the queue
    static func topPriorityLabels() throws -> [PullRequest.Label] {
        let labelsList: String = try Environment.get("TOP_PRIORITY_LABELS")
        return labelsList.split(separator: ",").map { name in
            PullRequest.Label(name: String(name))
        }
    }

    static func get(_ key: String) throws -> String {
        guard let value = Environment.get(key) as String?
            else { throw ConfigurationError.missingConfiguration(message: "💥 key `\(key)` not found in environment") }

        return value
    }
}
