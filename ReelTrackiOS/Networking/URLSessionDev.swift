import Foundation

extension URLSession {
    static var development: URLSession {
        let config = URLSessionConfiguration.default
        let delegate = DevURLSessionDelegate()
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }
}

class DevURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        #if DEBUG
        // In debug builds, accept any localhost certificate
        if challenge.protectionSpace.host == "localhost" {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
            return
        }
        #endif
        
        // Default handling for all other cases
        completionHandler(.performDefaultHandling, nil)
    }
} 