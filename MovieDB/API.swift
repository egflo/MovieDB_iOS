//
//  JSON_Parser.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/17/21.
//

import SwiftUI
import CoreData
import UIKit
import Combine


struct MyVariables {
    //static var API_IP = "http://10.81.1.123:8080/moviedb_api"
    static var API_IP = "http://127.0.0.1:8080/"
}


class User: ObservableObject {
    @Published var data = UserData()
    @Published var isLoggedin = false
    @Published var cart = [Movie: Int]()
    @Published var watchlist = Set<Movie>()
    

    func getFirstName() -> String {
        let first_name = data.firstName
        if(first_name.count > 1) {
            return first_name
        }
        else {
            return "First Name"
        }
    }
    
    func bookmarkStatus(movie:Movie) -> String {
        if(watchlist.contains(movie)) {
            return "bookmark.fill"
        }
        else {
            return "bookmark"
        }
    }
    
    func bookmark(movie: Movie) {
        if(!watchlist.contains(movie)){
            addMovieToWatchList(movie: movie)
        }
        else {
            removeMovieFromWatchList(movie: movie)
        }
    }
    
    private func addMovieToWatchList(movie: Movie) {
    
            watchlist.insert(movie)
   
    }
    
    private func removeMovieFromWatchList(movie: Movie) {
        if(watchlist.contains(movie)){
            let index = watchlist.firstIndex(of: movie)
            if let unwrapped = index {
                watchlist.remove(at: unwrapped)
            }
            else {
                return
            }
        }
    }
    
    func incrementQty(movie: Movie) {
        let qty = cart[movie] ?? 0
        if(qty <= 8){
            cart[movie] = qty + 1
        }
    }
    
    func decrementQty(movie: Movie) {
        let qty = cart[movie] ?? 0
        if(qty > 1){
            cart[movie] = qty - 1
        }
    }
    
    func getCartCount() -> Int {
        return cart.reduce(0) {$0 + $1.value}
    }
    
    func addToCart(movie: Movie) {
        
        if let qty = cart[movie] {
            // now val is not nil and the Optional has been unwrapped, so use it
            if(qty <= 8){
                cart[movie] = qty + 1
            }
        }
        else {
            cart[movie] = 1
        }
    }
    
    func removeFromCart(movie: Movie) {
        
        cart.removeValue(forKey: movie)
    }
    
    func getCartCountStr() -> String {
        var str_count: String
        
        let count = cart.reduce(0) {$0 + $1.value}
        if(count > 10) {
            str_count = "10+"
        }
        
        else {
            
            str_count = String(count)
        }
        
        return str_count
    }
    
    func calc_subTotal() -> String {
        let sub_total = cart.reduce(0) {$0 + ($1.0.price! * Double($1.1))}

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: sub_total))!
        
    }
    
}



class MovieDB_API: ObservableObject {
    @EnvironmentObject var user: User

    @Published var movie: Movie = Movie()
    @Published var cast: Cast = Cast()
    @Published var movies = [Movie]()
    
    
    @Published var rated = [Movie]()
    @Published var sellers = [Movie]()
    @Published var critic = [Movie]()


    
    func loadMoviesByCast(id: String) {

        let url = "\(MyVariables.API_IP)/movie/star/\(id)"
        print(url)

        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        
                        self.movies = decodedResponse.content

                    }
                    
                    // everything is good, so we can exit
                    return
                }
            }
        
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
    
    func loadCast(id: String) {
        let url = "\(MyVariables.API_IP)/star/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(Cast.self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        self.cast = decodedResponse
                    }
                    
                    // everything is good, so we can exit
                    return
                }
            }
        
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
    
    func loadMovie(id: String) {
        
        let url = "\(MyVariables.API_IP)/movie/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(Movie.self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        self.movie = decodedResponse

                    }
                    
                    // everything is good, so we can exit
                    return
                }
            }
        
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
    
}


class ContentDataSource: ObservableObject {
    
    @Published var items = [Movie]()
    @Published var isLoadingPage = false
    
    private var canLoadMorePages = true
    private var currentPage = 0
    private let pageSize = 10
    
    private var text = ""
    var query = ""

    init() { loadMoreContent() }
    
    
    func setText(text: String) {
        if(text.count < 1) {
            self.text = "T"
            return
        }
        else {
            self.text = text
            self.items = [Movie]()
        }
        
        self.canLoadMorePages = true
        self.currentPage = 0
        loadMoreContent()
    }

   func loadMoreContent() {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        if(self.query.isEmpty) {
            return
        }

        isLoadingPage = true
    
        let url = "\(MyVariables.API_IP)/movie/\(self.query)/\(self.text)?limit=\(self.pageSize)&page=\(self.currentPage)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        print(encoded_url)
    
        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
    
        URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Response.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.canLoadMorePages = !response.last
                self.isLoadingPage = false
                self.currentPage += 1
            })
            .map({ response in
                return self.items + response.content
            })
            .catch({ _ in Just(self.items) })
            .assign(to: &$items)
    }
}

