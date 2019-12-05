//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
@testable import RadixSDK

private var timeoutForLocalhostLookup = DispatchTime.distantFuture
func isConnectedToLocalhost(
    bootstrap: BootstrapConfig,
    timeout: DispatchTime? = nil
) -> Bool {
    if let timeout = timeout {
        timeoutForLocalhostLookup = timeout
    }

    var isConnected = false
    
    let url: URL
    
    switch bootstrap.discoveryMode {
    case .byDiscoveryEpics: return false
    case .byInitialNetworkOfNodes(let nodes):
        let baseUrl = nodes.contents[0].hypertextUrl.url
        url = baseUrl.appendingPathComponent("network")
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let (data, _, error) = URLSession(configuration: .default).synchronousDataTask(request: request)
    
    if let error = error {
        print("⚠️ Not connect to localhost, error: \(error)")
    } else if let _ = data {
        print("📡 Connected to localhost")
        isConnected = true
    }
    return isConnected
    
}

private extension URLSession {
    func synchronousDataTask(request: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: request) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}
