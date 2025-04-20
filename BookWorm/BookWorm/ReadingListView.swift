//
//  ReadingListView.swift
//  BookWorm
//
//  Created by Chidera Anayo Mbachi on 2025-04-16.
//

import SwiftUI
import CoreData

struct ReadingListView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var filterStatus = "all"
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BookEntry.addedDate, ascending: false)],
        animation: .default
    ) private var books: FetchedResults<BookEntry>

    var filteredBooks: [BookEntry] {
        let filter = filterStatus.lowercased()
        print("Filtering with status: \(filter), books: \(books.map { $0.status ?? "nil" })")
        if filter == "all" {
            return Array(books)
        }
        return books.filter { ($0.status ?? "").lowercased() == filter }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $filterStatus) {
                    Text("All").tag("all")
                    Text("To Read").tag("to-read")
                    Text("Reading").tag("reading")
                    Text("Finished").tag("finished")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .accentColor(.blue)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))


                if !books.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Raw statuses: \(books.map { $0.status ?? "nil" }.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Raw thumbnails: \(books.map { $0.thumbnail ?? "nil" }.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom)
                }

                List(filteredBooks, id: \.id) { book in
                    HStack {
                        
                        if let thumbnail = book.thumbnail, let url = URL(string: thumbnail), thumbnail.starts(with: "https://") {
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
                                    Image(systemName: "exclamationmark.triangle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 75)
                                        .foregroundColor(.red)
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
                            Text(book.title ?? "Unknown")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Author(s): \(book.authors ?? "Unknown")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Status: \(book.status?.capitalized ?? "Unknown")")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text("Progress: \(Int(book.progress * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 4)
                    .transition(.scale)
                }
                .animation(.easeInOut, value: filteredBooks)
                .overlay {
                    if filteredBooks.isEmpty {
                        VStack {
                            Image(systemName: "books.vertical")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                                .foregroundColor(.gray)
                            Text("No books in this category")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                    }
                }
            }
            .navigationTitle("Reading List")
            .background(Color(.systemGroupedBackground))
            .onAppear {
                print("Books statuses on appear: \(books.map { $0.status ?? "nil" })")
                print("Book thumbnails: \(books.map { $0.thumbnail ?? "nil" })")
            }
        }
    }
}
