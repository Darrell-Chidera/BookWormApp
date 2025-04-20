//
//  ProfileView.swift
//  BookWorm
//
//  Created by Chidera Anayo Mbachi on 2025-04-16.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var books: FetchedResults<BookEntry>

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = viewModel.user {
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .foregroundColor(.blue)
                        Text("Welcome, \(user.email ?? "User")")
                            .font(.title2)
                            .foregroundColor(.primary)
                        Text("Books Added: \(books.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Button(action: {
                        withAnimation {
                            viewModel.signOut()
                        }
                    }) {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                    }
                } else {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Button(action: {
                        withAnimation {
                            viewModel.signIn()
                        }
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                    }
                    Button(action: {
                        withAnimation {
                            viewModel.signUp()
                        }
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                    }
                    if let error = viewModel.error {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .animation(.easeInOut, value: viewModel.user)
        }
    }
}

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var email = ""
    @Published var password = ""
    @Published var error: Error?

    init() {
        user = Auth.auth().currentUser
    }

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign-in error: \(error.localizedDescription) (\(error._code))")
                self.error = error
                return
            }
            self.user = result?.user
            self.error = nil
        }
    }

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign-up error: \(error.localizedDescription) (\(error._code))")
                self.error = error
                return
            }
            self.user = result?.user
            self.error = nil
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            print("Sign-out error: \(error.localizedDescription)")
            self.error = error
        }
    }
}
