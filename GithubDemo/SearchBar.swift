//
//  SearchBar.swift
//  GithubDemo
//
//  Created by Paul Solt on 9/5/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import Foundation
import SwiftUI
import Combine



//var publisher: AnyPublisher<String?, Never> {
//    var t = Text("hi")
//    var searchBar = UISearchBar()
//    return AnyPublisher(searchBar.publisher(for: \.text))
//}

typealias SearchCompletion = () -> Void

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var completion: SearchCompletion? = nil
    
    init(text: Binding<String>, onChange completion: SearchCompletion? = nil) {
        _text = text
        self.completion = completion
    }
    
    // The coordinator allows us to listen for updates to our searchbar
    class SearchBarCoordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var completion: SearchCompletion?
        
        init(text: Binding<String>, onChange completion: SearchCompletion? = nil) {
            _text = text
            self.completion = completion
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            completion?()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            completion?()
        }
    }
    
    func makeCoordinator() -> SearchBarCoordinator {
        return SearchBarCoordinator(text: $text, onChange: completion)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ searchBar: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        searchBar.text = text
    }
}



// Does this work??? Seems buggy with keyboard simulator
//    func updateUIView(_ searchBar: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
//        print("Update searchBar")
//        searchBar.text = text
//
//        if searchBar.window != nil, !searchBar.isFirstResponder {  // checking window prevents crash in a sheet before in view hierarchy
//            searchBar.becomeFirstResponder()
//        }
//    }
//}
