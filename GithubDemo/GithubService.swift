//
//  GithubService.swift
//  GithubDemo
//
//  Created by Paul Solt on 9/4/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import Foundation
import Combine

// Based on https://mecid.github.io/2019/06/05/swiftui-making-real-world-app/

struct Repository: Decodable, Identifiable {
    let id: Int
    let name: String
    let description: String?
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

enum GithubServiceError: Error {
    case noData
    case invalidJSON(error: Error)
    case apiError(message: String)
}

typealias GithubServiceHandler = (Result<[Repository], Error>) -> Void

class GithubService {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURLString: String
    
    static let githubURL = "https://api.github.com/search/repositories"
    
    init(session: URLSession = .shared, decoder: JSONDecoder = .init(), baseURLString: String = GithubService.githubURL) {
        self.session = session
        self.decoder = decoder
        self.baseURLString = baseURLString
    }
    
    func searchRepositories(matching query: String, handler: @escaping GithubServiceHandler) {
        guard var urlComponents = URLComponents(string: baseURLString) else {
            preconditionFailure("Cannot connect to URL address")
        }
        urlComponents.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let url = urlComponents.url else {
            preconditionFailure("Cannot make url from url components")
        }
        print("URL: \(url)")
        session.dataTask(with: url) { (data, _, error) in
            if let error = error {
                handler(.failure(error))
            } else {
                guard let data = data else {
                    handler(.failure(GithubServiceError.noData))
                    return
                }
                do {
                    //print(String(data: data, encoding: .utf8))
                    let response = try self.decoder.decode(SearchResponse.self, from: data)
                    handler(.success(response.items))
                } catch {
                    if let response = try? self.decoder.decode(GithubAPIResponse.self, from: data) {
                        handler(.failure(GithubServiceError.apiError(message: "\(response)")))
                    } else {
                        handler(.failure(GithubServiceError.invalidJSON(error: error)))
                    }
                }
            }
        }.resume()
    }
}

