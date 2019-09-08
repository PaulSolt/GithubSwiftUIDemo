//
//  SearchView.swift
//  GithubDemo
//
//  Created by Paul Solt on 9/4/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import SwiftUI

class RepositoryStore: ObservableObject {
    @Published private(set) var repositories: [Repository] = []
    
    private let service: GithubService
    
    init(service: GithubService) {
        self.service = service
    }
    
    func fetchRepositories(matching query: String) {
        service.searchRepositories(matching: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let repositories):
                    self?.repositories = repositories
                case .failure(let error):
                    print("Error fetching repositories: \(error)")
                    self?.repositories = []
                }
            }
        }
    }
}

class SearchStore: ObservableObject {
    @Published var query: String = "PaulSolt"

}

struct SearchView: View {
    
//    @Published private var query: String = "PaulSolt"
    @State private var query: String = "PaulSolt" //"Swift"
//    @Published var query: String = "PaulSolt"
    
    @EnvironmentObject var repositoryStore: RepositoryStore
    
    var body: some View {
        NavigationView {
            
            VStack {
                // 2nd approach
//                SearchBar(text: $query) {
//                    print("query: \(self.query)")
//                    self.fetch()
//                }

                // 1st Approach
//                TextField("Type something...", text: $query, onCommit: {
//                    self.fetch()
//                    // hide keyboard
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
//                })
//                .padding()
//                .background(
//                    RoundedRectangle(cornerRadius: 5, style: .continuous)
//                        .foregroundColor(Color(white:0.95))
//                )
//                .padding()
                
                List {

                                    
                    // TODO publish debounce / duplicates
                    ForEach(repositoryStore.repositories) { repository in
                        RepositoryRow(repository: repository)
                    }
                }
            }.navigationBarTitle(Text("Search"))
        }.onAppear {
//            fetch()
            // TODO: How do I change focus to the TextField() above
        }
        // (perform: fetch)
    }
    
    private func fetch() {
        repositoryStore.fetchRepositories(matching: query)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(
                RepositoryStore(service: GithubService())
        )
    }
}
