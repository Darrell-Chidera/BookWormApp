//
//  BookModel.swift
//  BookWorm
//
//  Created by Chidera Anayo Mbachi on 2025-04-16.
//

import Foundation

struct BookSearchResult: Codable {
    let items: [BookItem]?
}

struct BookItem: Codable, Identifiable, Equatable {
    let id: String
    let volumeInfo: VolumeInfo
    
    static func == (lhs: BookItem, rhs: BookItem) -> Bool {
            return lhs.id == rhs.id
        }
}

struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let imageLinks: ImageLinks?
}

struct ImageLinks: Codable {
    let thumbnail: String?
}
