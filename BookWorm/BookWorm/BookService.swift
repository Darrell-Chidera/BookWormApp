//
//  BookService.swift
//  BookWorm
//
//  Created by Chidera Anayo Mbachi on 2025-04-16.
//

import Foundation

class BookService {
    func fetchBooks(query: String, completion: @escaping (Result<[BookItem], Error>) -> Void) {
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(queryEncoded)"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            do {
                let response = try JSONDecoder().decode(BookSearchResult.self, from: data)
                completion(.success(response.items ?? []))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
