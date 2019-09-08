//
//  TestNetworking.swift
//  GithubDemo
//
//  Created by Paul Solt on 9/7/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import Foundation
import Combine

// Based on



enum APIError: Error, LocalizedError {
    case unknown, apiError(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason):
            return reason
        }
    }
}

enum HTTPError: LocalizedError {
    case statusCode(Int)
    case invalidResponse(String)
}

struct Post: Codable {
    
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

func downloadPostPublisher(from url: URL) -> AnyPublisher<[Post], Error> {
    return URLSession.shared.dataTaskPublisher(for: url)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPError.invalidResponse("Invalid response: \(response)")
            }
            
            guard httpResponse.statusCode == 200 else {
                throw HTTPError.statusCode(httpResponse.statusCode)
            }
            
            return data
    }
    .decode(type: [Post].self, decoder: JSONDecoder())  // will fail (amazon.com)
    .eraseToAnyPublisher()
}

var networkRequest: AnyCancellable?
func testRequest() {
    guard let url = URL(string: "https://www.amazon.com") else { return }
    
    // Must hold onto the request
    networkRequest = downloadPostPublisher(from: url)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                fatalError("\(error)")
            }
        }, receiveValue: { posts in
            print(posts.count)
        })
}

func fetch(url: URL) -> AnyPublisher<Data, APIError> {
    let request = URLRequest(url: url)
    
    return URLSession.DataTaskPublisher(request: request, session: .shared)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw APIError.unknown
            }
            return data
    }
    .mapError { error in
        if let error = error as? APIError {
            return error
        } else {
            return APIError.apiError(reason: error.localizedDescription)
        }
    }
    .eraseToAnyPublisher()
}

// Usage
var request: AnyCancellable?

func downloadTest() {
    guard let url = URL(string: "https://www.amazon.com") else { return }
    request = fetch(url: url)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, receiveValue: { data in
            guard let response = String(data: data, encoding: .utf8) else { return }
            print(response)
        })
}

func search(text: String, handler: @escaping GithubServiceHandler) {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    
    //    self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
    //    .map { $0.data }
    //    .decode(type: [Post].self, decoder: JSONDecoder())
    //    .replaceError(with: [])
    //    .eraseToAnyPublisher()
    //    .assign(to: \.posts, on: self)
    
    
    
}
