import Bot
import Vapor

public func routes(_ router: Router, logger: LoggerProtocol, gitHubEventsService: GitHubEventsService) throws {

    router.post("github") { request -> HTTPResponse in
        switch gitHubEventsService.handleEvent(from: request).first() {
        case .success?:
            return HTTPResponse(status: .ok)
        case .failure?, .none:
            return HTTPResponse(status: .badRequest)
        }
    }
}
