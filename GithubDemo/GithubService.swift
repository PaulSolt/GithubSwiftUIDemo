//
//  GithubService.swift
//  GithubDemo
//
//  Created by Paul Solt on 9/4/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import Foundation

// Based on https://mecid.github.io/2019/06/05/swiftui-making-real-world-app/

struct Repository: Decodable, Identifiable {
    let id: Int
    let name: String
    let description: String
}

struct GithubAPIResponse: Decodable {
    let message: String
    let errors: [APIError]?
    let documentationURL: URL
    
    enum CodingKeys: String, CodingKey {
        case message
        case errors
        case documentationURL = "documentation_url"
    }
    
    struct APIError: Decodable {
        let resource: String
        let field: String
        let code: String
    }
}


struct SearchResponse: Decodable {
    let items: [Repository]
}

class GithubService {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    typealias GithubServiceHandler = (Result<[Repository], Error>) -> Void
    
    let baseURLString = "https://api.github.com/search/repositories"
    
    func searchRepositories(matching query: String, handler: @escaping GithubServiceHandler) {
        guard var urlComponents = URLComponents(string: baseURLString) else {
            preconditionFailure("Cannot connect to URL address")
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        guard let url = urlComponents.url else {
            preconditionFailure("Cannot make url from url components")
        }
        
        // When to use [weak self] with a closure. It's bogglign my mind
        // Weak self seems to complicate this situation, and the closure only has a strong
        // reference as long as it is running, when it fails, it completes
        session.dataTask(with: url) { (data, _, error) in
            
            //        session.dataTask(with: url) { [weak self] (data, _, error) in
            //          guard self = self { else handler(.failure(.weakSelf))} // option2: Do something here
            
            if let error = error {
                handler(.failure(error))
            } else {
                guard let data = data else {
                    handler(.failure(GithubError.noData))
                    return
                }
                do {
//                    print(String(data: data, encoding: .utf8))
                    let response = try self.decoder.decode(SearchResponse.self, from: data)
                    handler(.success(response.items)) // option1: potentially giving [] when self is nil
                    
                    //                    let response = try self?.decoder.decode(SearchResponse.self, from: data) // option1: weak self
                    //                    handler(.success(response?.items ?? [])) // option1: potentially giving [] when self is nil
                } catch {
                    if let response = try? self.decoder.decode(GithubAPIResponse.self, from: data) {
                        handler(.failure(GithubError.apiError(message: "\(response)")))
                    } else {
                        
                    }
                    
                    handler(.failure(GithubError.invalidJSON))
                }
            }
        }.resume()
    }
}

enum GithubError: Error {
    case noData
    case invalidJSON
    case apiError(message: String)
}
