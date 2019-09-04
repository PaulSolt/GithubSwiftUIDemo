//
//  RepositoryRow.swift
//  GithubDemo
//
//  Created by Paul Solt on 9/4/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import SwiftUI

struct RepositoryRow: View {
    let repository: Repository
    
    var body: some View {
        VStack {
            Text(repository.name)
                .font(.headline)
            Text(repository.description)
                .font(.subheadline)
        }
    }
}

let repositoryData = Repository(id: 1, name: "Things", description: "A Todo app")

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryRow(repository: repositoryData)
    }
}
