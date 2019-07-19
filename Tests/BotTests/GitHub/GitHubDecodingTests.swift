import XCTest
import Nimble
@testable import Bot

class GitHubDecodingTests: XCTestCase {

    func test_parsing_pull_request() {
        let decoder = JSONDecoder()
        let data = GitHubPullRequest.data(using: .utf8)!

        do {
            let pullRequest = try decoder.decode(PullRequest.self, from: data)
            expect(pullRequest.number) == 1347
            expect(pullRequest.title) == "new-feature"
            expect(pullRequest.author) == PullRequest.Author(login: "octocat")
            expect(pullRequest.source) == PullRequest.Branch(ref: "new-topic", sha: "6dcb09b5b57875f334f61aebed695e2e4193db5e")
            expect(pullRequest.target) == PullRequest.Branch(ref: "master", sha: "6dcb09b5b57875f334f61aebed695e2e4193db5e")
            expect(pullRequest.labels) == [.init(name: "bug")]
        } catch let error {
            fail("Could not parse a pull request with error: \(error)")
        }
    }

    func test_parsing_pull_request_event_context() {
        let decoder = JSONDecoder()
        let data = GitHubPullRequestEvent.data(using: .utf8)!

        do {
            let context = try decoder.decode(PullRequestEvent.self, from: data)
            expect(context.pullRequestMetadata.reference.number) == 1
            expect(context.pullRequestMetadata.reference.title) == "Update the README with new information"
            expect(context.pullRequestMetadata.reference.author) == PullRequest.Author(login: "Codertocat")
            expect(context.pullRequestMetadata.reference.source) == PullRequest.Branch(ref: "changes", sha: "34c5c7793cb3b279e22454cb6750c80560547b3a")
            expect(context.pullRequestMetadata.reference.target) == PullRequest.Branch(ref: "master", sha: "a10867b14bb761a232cd80139fbd4c0d33264240")
            expect(context.pullRequestMetadata.reference.labels) == [.init(name: "bug")]
            expect(context.pullRequestMetadata.isMerged) == false
            expect(context.pullRequestMetadata.mergeState) == .clean
            expect(context.action) == .closed
        } catch let error {
            fail("Could not parse a pull request with error: \(error)")
        }
    }

    func test_parsing_status_event_context() {
        let decoder = JSONDecoder()
        let data = GitHubStatusEvent.data(using: .utf8)!

        do {
            let statusChange = try decoder.decode(StatusChange.self, from: data)
            expect(statusChange.sha) == "a10867b14bb761a232cd80139fbd4c0d33264240"
            expect(statusChange.context) == "default"
            expect(statusChange.description).to(beNil())
            expect(statusChange.state) == .success
            expect(statusChange.branches) == [
                StatusChange.Branch(name: "master"),
                StatusChange.Branch(name: "changes"),
                StatusChange.Branch(name: "gh-pages")
            ]
        } catch let error {
            fail("Could not parse a pull request with error: \(error)")
        }
    }
}

