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

struct SearchView: View {
    @State private var query: String = "Swift"
    @EnvironmentObject var repositoryStore: RepositoryStore

    var body: some View {
        NavigationView {

            List {
                HStack {
                    Text("Search")
                        .font(.headline)
                    TextField("Type something...", text: $query, onCommit: fetch)
                }
                // TODO publish debounce / duplicates
                ForEach(repositoryStore.repositories) { repository in
                    RepositoryRow(repository: repository)
                }
            }.navigationBarTitle(Text("Search"))
        }.onAppear(perform: fetch)
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
