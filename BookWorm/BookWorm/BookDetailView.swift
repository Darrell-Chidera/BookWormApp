//
//  BookDetailView.swift
//  BookWorm
//
//  Created by Chidera Anayo Mbachi on 2025-04-20.
//

import SwiftUI
import FirebaseAuth

struct BookDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel = BookDetailViewModel()
    @State private var status = "to-read"
    @State private var progress = 0.0
    @State private var review = ""
    @State private var showAlert = false
    let book: BookItem

    var body: some View {
        Form {
            Section(header: Text("Book Details").font(.headline).foregroundColor(.blue)) {
                Text(book.volumeInfo.title)
                    .font(.title3)
                    .foregroundColor(.primary)
                Text("Author(s): \(book.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let thumbnail = book.volumeInfo.imageLinks?.thumbnail, let url = URL(string: thumbnail) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 100)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 2)
                        case .failure:
                            Image(systemName: "book.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .foregroundColor(.gray)
                        @unknown default:
                            Image(systemName: "book.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            Section(header: Text("Reading Status").font(.headline).foregroundColor(.blue)) {
                Picker("Status", selection: $status) {
                    Text("To Read").tag("to-read")
                    Text("Reading").tag("reading")
                    Text("Finished").tag("finished")
                }
                .pickerStyle(.menu)
                .accentColor(.blue)
                Slider(value: $progress, in: 0...1, step: 0.1) {
                    Text("Progress")
                }
                .accentColor(.blue)
                Text("Progress: \(Int(progress * 100))%")
                    .foregroundColor(.secondary)
            }
            Section(header: Text("Review").font(.headline).foregroundColor(.blue)) {
                TextEditor(text: $review)
                    .frame(height: 100)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Button(action: {
                if Auth.auth().currentUser?.uid == nil {
                    showAlert = true
                    return
                }
                withAnimation {
                    viewModel.addBook(book: book, status: status, progress: progress, review: review, context: context)
                }
            }) {
                Text("Add Book")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isAdding ? Color.gray : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            }
            .disabled(viewModel.isAdding)
            .padding(.vertical)
        }
        .navigationTitle("Add Book")
        .background(Color(.systemGroupedBackground))
        .alert("Error", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text("Please sign in to add books.")
        }
    }
}
