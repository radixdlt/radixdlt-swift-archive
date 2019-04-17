//
//  IsConnectedToLocalhost.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

var isConnectedToLocalhost: Bool = {
    var isConnected = false
    let url = URL(string: "http://localhost:8080/api/network")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let (data, response, error) = URLSession(configuration: .default)
        .synchronousDataTask(request: request)
    if let error = error {
        print("Connect to localhost error: \(error)")
    } else if let _ = data {
        print("Connected to localhost")
        isConnected = true
    }
    return isConnected
}()

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
