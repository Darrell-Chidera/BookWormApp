//
//  BookSearchViewModel.swift
//  BookWorm
//
//  Created by Chidera Anayo Mbachi on 2025-04-20.
//
import SwiftUI

class BookSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var books: [BookItem] = []
    @Published var showError = false
    @Published var errorMessage = ""

    func searchBooks() {
        guard !searchText.isEmpty else {
            books = []
            return
        }

        let query = searchText.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query)"
        guard let url = URL(string: urlString) else {
            showError = true
            errorMessage = "Invalid search URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showError = true
                    self.errorMessage = "Search failed: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.showError = true
                    self.errorMessage = "No data received"
                    return
                }
                do {
                    let result = try JSONDecoder().decode(BookSearchResult.self, from: data)
                    self.books = result.items ?? []
                    print("Search results thumbnails: \(self.books.map { $0.volumeInfo.imageLinks?.thumbnail ?? "nil" })")
                    print("Search results imageLinks: \(self.books.map { String(describing: $0.volumeInfo.imageLinks) })")
                } catch {
                    self.showError = true
                    self.errorMessage = "Error decoding data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct BookSearchView_Previews: PreviewProvider {
    static var previews: some View {
        BookSearchView()
    }
}
