//
//  iTunesAPI.swift
//  iTunesSwiftUI
//
//  Created by Dimitri Bouniol Lambda on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

public class iTunesAPI {
    public struct Artist : Codable {
        public var artistName: String
        public var primaryGenreName: String
    }
    
    public enum SearchError : Error {
        case invalidSearchTerm
        case dataTask(Error)
        case invalidServerResponse
        case unexpectedHTTPResponse(Int)
        case invalidStateMissingData
        case invalidStateCouldNotParseJSON(Error)
    }
    
    private static let baseURL = URL(string: "https://itunes.apple.com/search")!
    
    public static func searchArtists(for searchTerm: String, completion: @escaping ((Result<[Artist], SearchError>) -> Void)) {
        guard !searchTerm.isEmpty else {
            completion(.failure(.invalidSearchTerm))
            return
        }
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "term", value: searchTerm)]
        
        let url = urlComponents.url!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.dataTask(error))) }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(.invalidServerResponse)) }
                return
            }
            
            guard 200...299 ~= response.statusCode else {
                DispatchQueue.main.async { completion(.failure(.unexpectedHTTPResponse(response.statusCode))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.invalidStateMissingData)) }
                return
            }
            
            do {
                struct SearchResponse: Codable {
                    let results: [Artist]
                }
                
                let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(searchResponse.results)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.invalidStateCouldNotParseJSON(error))) }
            }
            
        }.resume()
    }
}
