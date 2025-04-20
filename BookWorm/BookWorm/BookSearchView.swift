//
//  BookSearchView.swift
//  BookWorm
//
//  Created by Chidera Anayo Mbachi on 2025-04-16.
//

import SwiftUI

struct BookSearchView: View {
    @StateObject private var viewModel = BookSearchViewModel()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search books...", text: $viewModel.searchText, onCommit: {
                    viewModel.searchBooks()
                })
                .textFieldStyle(.roundedBorder)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .autocapitalization(.none)

                List(viewModel.books) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        HStack {
                            if let thumbnail = book.volumeInfo.imageLinks?.thumbnail, let url = URL(string: thumbnail) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 50, height: 75)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 75)
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                            .shadow(radius: 2)
                                    case .failure:
                                        Image(systemName: "book.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 75)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        Image(systemName: "book.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 75)
                                            .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 75)
                                    .foregroundColor(.gray)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(book.volumeInfo.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Author(s): \(book.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 4)
                    }
                    .transition(.scale)
                }
                .animation(.easeInOut, value: viewModel.books)
                .overlay {
                    if viewModel.books.isEmpty && !viewModel.searchText.isEmpty {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                                .foregroundColor(.gray)
                            Text("No books found")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                    }
                }
            }
            .navigationTitle("Search Books")
            .background(Color(.systemGroupedBackground))
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

