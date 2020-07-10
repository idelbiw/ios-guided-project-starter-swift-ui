//
//  SearchView.swift
//  iTunesSwiftUI
//
//  Created by Waseem Idelbi on 7/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import SwiftUI

final class SearchBar: NSObject, UIViewRepresentable {
    
    @Binding var artistName: String
    @Binding var artistGenre: String
    
    init(artistName: Binding<String> = .constant(""), artistGenre: Binding<String> = .constant("")) {
        _artistName = artistName
        _artistGenre = artistGenre
    }
    
    typealias UIViewType = UISearchBar
    
    func makeUIView(context: Context) -> UISearchBar {
                
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
        
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        
        uiView.delegate = self
        
    }
    
}

extension SearchBar: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchTerm = searchBar.text else { return }
        
        artistName = searchBar.text!
        
        iTunesAPI.searchArtists(for: searchTerm) { (result) in
            
            do {
                
                let artist = try result.get()
                
                guard let firstArtist = artist.first else {
                    self.artistName = "Error seach for artist"
                    self.artistGenre = ""
                    return
                }
                
                self.artistName = firstArtist.artistName
                self.artistGenre = firstArtist.primaryGenreName
                
            } catch {
                
                NSLog("No artist found")
                self.artistName = "Error seach for artist"
                self.artistGenre = ""
            }
            
        }
        
    }
    
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}
