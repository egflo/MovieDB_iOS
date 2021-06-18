//
//  MainView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/30/21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct GenreMain: View {
    @State private var genres = [MovieMeta]()
    
    

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(genres, id: \.name) { genre in
                        let genre_data = Genre(genreId: genre.id!, name: genre.name!)
                        NavigationLink(destination: GenreView(genre: genre_data)){
                            ZStack{
                                
                                Image("background")
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .cornerRadius(8)

                                
                                Text(genre.name!).font(.system(size: 30)).bold().foregroundColor(.white).shadow(radius: 5)
                                
                            }
                            .frame(height: 100)
                        }
                    
                    }
                }.onAppear{loadGenres()}
            }
        }
        
    func loadGenres() {
        
        let url = "\(MyVariables.API_IP)/genre/all"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([MovieMeta].self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        self.genres = decodedResponse
                    }
                    
                    // everything is good, so we can exit
                    return
                }
            }
        
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
    
}


struct ImageCarouselView: View {
    //@EnvironmentObject var movie_api: MovieDB_API
    @EnvironmentObject var user: User

    @State private var currentIndex: Int = 0
    @State var movies = [Movie]()
    
    private var type: Int
    private var number_of_images = 5
    
    
    @State var width = (UIScreen.main.bounds.width - 15)
    @State var height = (UIScreen.main.bounds.height - 33)
    
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    init(type: Int, number_of_images: Int ) {
        self.type = type
        self.number_of_images = number_of_images
    }

    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false){
            if UIDevice.current.userInterfaceIdiom == .pad {
                // Available Idioms - .pad, .phone, .tv, .carPlay, .unspecified
                // Implement your logic here
                HStack {
                    ForEach(movies, id: \.uuid) { movie in
                        let m = MovieDecode(movie:movie)
                        NavigationLink(destination: MovieView(movie: movie)){
                            ZStack (alignment: .bottomLeading){
                                WebImage(url: URL(string: m.background()))
                                        .placeholder(Image(systemName: "livephoto.slash"))
                                        .resizable()
                                        .frame(width: 400, height: 220, alignment: .center)
                                        .scaledToFill()
                                        .clipped()
                                        .cornerRadius(8)
                                  
                                
                                VStack(alignment: .leading) {
                                    Text(m.title()).font(.system(size: 30)).bold().foregroundColor(.white).shadow(radius: 5)
                                    Text(m.subString()).font(.subheadline).bold().foregroundColor(.white).shadow(radius: 5)

                                }
                                .padding(.bottom,15)
                                .padding(.leading,10)
                                
                            }.frame(width: 400, height: 220, alignment: .center)

                        }
                    }

                }
                
            }
            
            else {
                
                HStack {
                    ForEach(movies, id: \.uuid) { movie in
                        let m = MovieDecode(movie:movie)
                        NavigationLink(destination: MovieView(movie: movie)){
                            ZStack (alignment: .bottomLeading){
                                WebImage(url: URL(string: m.background()))
                                        .placeholder(Image(systemName: "livephoto.slash"))
                                        .resizable()
                                        .frame(width: (UIScreen.main.bounds.width - 40), height: 200, alignment: .center)
                                        .scaledToFill()
                                        .clipped()
                                        .cornerRadius(8)
                                  
                                
                                VStack(alignment: .leading) {
                                    Text(m.title()).font(.system(size: 30)).bold().foregroundColor(.white).shadow(radius: 5)
                                    Text(m.subString()).font(.subheadline).bold().foregroundColor(.white).shadow(radius: 5)

                                }
                                .padding(.bottom,15)
                                .padding(.leading,10)
                                
                            }.frame(width: (UIScreen.main.bounds.width - 40), height: 200, alignment: .center)
                            
                        }
                    }

                }
                
            }

        }.onAppear{self.loadMetaData()}
    }
    func loadMetaMovie(id: String) {
        
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
                        self.movies.append(decodedResponse)

                    }
                    
                    // everything is good, so we can exit
                    return
                }
            }
        
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
    
    func loadMetaData() {
        
        var url = ""
        
        if(type == 0) {
            
            url = "\(MyVariables.API_IP)/order/sellers?limit=\(number_of_images)"

        }
        
        else if(type == 1) {
            url = "\(MyVariables.API_IP)/rating/rated?limit=\(number_of_images)"
        }
        
        else if(type == 2) {
            url = "\(MyVariables.API_IP)/rating/critic?limit=\(number_of_images)"
        }
        
        else if(type == 3) {
            for movie in user.watchlist {
                self.loadMetaMovie(id: movie.id)
            }
            return
        }
        
        else {
            url = "\(MyVariables.API_IP)/order/sellers?limit=\(number_of_images)"

        }
        

        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(ResponseMeta.self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        let content = decodedResponse.content
                        for data in content {
                            self.loadMetaMovie(id: data.movieId!)
                        }

                    }
                    
                    // everything is good, so we can exit
                    return
                }
            }
        
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
}

struct MainView: View {
    @EnvironmentObject var user: User

    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    var body: some View {
        
        ScrollView
        {

            
            if(user.watchlist.count > 0){
                Text("Your Watchlist").font(.title).bold().padding(.leading,15).frame(width: UIScreen.main.bounds.width, alignment:.leading)
                ImageCarouselView(type:3, number_of_images: user.watchlist.count).padding(.leading,15)
                let _ = print("\(user.watchlist.count)")

            }
            
            Text("Top Sellers").font(.title).bold().padding(.leading,15).frame(width: UIScreen.main.bounds.width, alignment:.leading)
            
            ImageCarouselView(type: 0, number_of_images: 5).padding(.leading,15)
           
            Text("Top Rated").font(.title).bold().padding(.leading,15).frame(width: UIScreen.main.bounds.width, alignment:.leading)
            
            ImageCarouselView(type: 1, number_of_images: 5).padding(.leading,15)

            
            Text("Critically Acclaimed").font(.title).bold().padding(.leading,15).frame(width: UIScreen.main.bounds.width, alignment:.leading)
            
            ImageCarouselView(type: 2, number_of_images: 5).padding(.leading,15)

            
            Text("Genres").font(.title).bold().padding(.leading,15).frame(width: UIScreen.main.bounds.width, alignment:.leading)
            
            GenreMain().padding(.leading,15)
            
        }.offset(y: 15)
        
        .navigationBarHidden(true)

        .background(
            HStack {
                NavigationLink(destination: MainView(), isActive: $HomeActive) {EmptyView()}
                NavigationLink(destination: SearchView(), isActive: $SearchActive) {EmptyView()}
                NavigationLink(destination: UserView(), isActive: $UserActive) {EmptyView()}
                NavigationLink(destination: OrderView(), isActive: $OrderActive) {EmptyView()}
                NavigationLink(destination: CartView(), isActive: $CartActive) {EmptyView()}
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }
            }

        )
        
        .toolbar {
          ToolbarItem(placement: .bottomBar) {
            HStack{
                Button(action: {
                    self.HomeActive = true
                })
                {
                    Image(systemName: "house").imageScale(.large)
                }
                Button(action: {
                    self.SearchActive = true
                })
                {
                    Image(systemName: "magnifyingglass").imageScale(.large)
                }
                
                Button(action: {
                    self.UserActive = true
                })
                {
                    Image(systemName: "person.crop.circle").imageScale(.large)
                }
                
                Button(action: {
                    self.OrderActive = true
                })
                {
                    Image(systemName: "shippingbox").imageScale(.large)
                }
                
                Button(action: {
                    self.CartActive = true

                })
                {
                     let count = user.getCartCount()
                     
                     if(count == 0) {
                         
                         Image(systemName: "cart").imageScale(.large)

                     }
                     else{
                         ZStack {
                             Image(systemName: "cart").imageScale(.large)
                             Text("\(user.getCartCountStr())")
                                 .foregroundColor(Color.black)
                                 .background(Capsule().fill(Color.orange).frame(width:30, height:20))
                                 .offset(x:20, y:-10)

                         }
                         
                     }
                    
                }
            }
          }
        }

    }

}

