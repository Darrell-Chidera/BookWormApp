//
//  BookWormApp.swift
//  BookWorm
//
//  Created by Chidera Anayo Mbachi on 2025-04-16.
//

import SwiftUI
import FirebaseCore

@main
struct BookWormApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()
        print("Firebase configured successfully")
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                BookSearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                ReadingListView()
                    .tabItem {
                        Label("Reading List", systemImage: "book")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
