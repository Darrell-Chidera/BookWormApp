//
//  BookDetailViewModel.swift
//  BookWorm
//
//  Created by Chidera Anayo Mbachi on 2025-04-20.
//

import SwiftUI
import CoreData
import FirebaseAuth
import FirebaseFirestore

class BookDetailViewModel: ObservableObject {
    @Published var isAdding = false

    func addBook(book: BookItem, status: String, progress: Double, review: String, context: NSManagedObjectContext) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            isAdding = false
            return
        }

        isAdding = true
        let newBook = BookEntry(context: context)
        newBook.id = book.id
        newBook.title = book.volumeInfo.title
        newBook.authors = book.volumeInfo.authors?.joined(separator: ", ")
        let thumbnail = book.volumeInfo.imageLinks?.thumbnail
        newBook.thumbnail = thumbnail?.starts(with: "https://") == true ? thumbnail : thumbnail?.replacingOccurrences(of: "http://", with: "https://")
        newBook.status = status.lowercased()
        newBook.progress = progress
        newBook.review = review
        newBook.addedDate = Date()

        do {
            try context.save()
            print("Saved to CoreData: id=\(newBook.id ?? "No ID"), status=\(newBook.status ?? "nil"), thumbnail=\(newBook.thumbnail ?? "nil")")
            syncToFirestore(bookEntry: newBook, userId: userId)
            isAdding = false
        } catch {
            print("Error saving to CoreData: \(error.localizedDescription)")
            isAdding = false
        }
    }

    private func syncToFirestore(bookEntry: BookEntry, userId: String) {
        guard let bookId = bookEntry.id, !bookId.isEmpty else {
            print("Invalid book ID, cannot sync to Firestore")
            return
        }

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "id": bookEntry.id ?? "",
            "title": bookEntry.title ?? "",
            "authors": bookEntry.authors ?? "",
            "thumbnail": bookEntry.thumbnail ?? "",
            "status": bookEntry.status ?? "",
            "progress": bookEntry.progress,
            "review": bookEntry.review ?? "",
            "addedDate": bookEntry.addedDate ?? Date()
        ]

        db.collection("users").document(userId).collection("books").document(bookId).setData(data) { error in
            if let error = error {
                print("Error syncing to Firestore: \(error.localizedDescription) (\(error._code))")
            } else {
                print("Successfully synced book to Firestore: \(bookId)")
            }
        }
    }
}
