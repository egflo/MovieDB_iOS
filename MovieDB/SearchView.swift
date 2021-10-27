//
//  ContentView.swift
//  MovieDB
//
//

import SwiftUI
import CoreData
import UIKit
import URLImage
import SDWebImageSwiftUI
import Combine
import WrappingHStack

struct SimplifiedMovieView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    var user: UserData
    var meta: MovieMeta
    @State var isActive = false;

    @State var movie = Movie()

    var body: some View {
        NavigationLink(destination: MovieView(movie: movie), isActive: $isActive) {
            let m = MovieDecode(movie: movie)
            
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                WebImage(url: m.posterURL())
                        .resizable()
                        .renderingMode(.original)
                        .placeholder(Image("no_image"))
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .frame(width: 80, height: 115)
                

            }
            else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                
                WebImage(url: m.posterURL())
                        .resizable()
                        .renderingMode(.original)
                        .placeholder(Image("no_image"))
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .frame(width: 150, height: 200)


            }
            else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                
                WebImage(url: m.posterURL())
                        .resizable()
                        .renderingMode(.original)
                        .placeholder(Image("no_image"))
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .frame(width: 150, height: 200)

            }
        }
        .padding(.top, 5)
        .onAppear(perform: {self.getMovieData()})
    }
    
    func getMovieData() {
        API(user: user).getMovie(id: meta.movieId!) { (result) in
            switch result {
            case .success(let movie):
                DispatchQueue.main.async {
                    self.movie = movie
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

//https://github.com/dkk/WrappingHStack
struct MostSearchedView: View {
    @EnvironmentObject var user: UserData
    @State var movies = [MovieMeta]()
    let width = UIScreen.main.bounds.width


    var body: some View {
        
        ScrollView {
            VStack {
                Text("Top Searches").font(.title2).bold()
                    .frame(width:width, alignment: .leading)
                                
                WrappingHStack(movies, id: \.self) { meta in
                        SimplifiedMovieView(user: user, meta: meta)
                }
            }.frame(width: width ,alignment: .center)
            
        }
        .frame(width: width ,alignment: .center)
        .padding(.leading, 33)
        .onAppear(perform: {self.getMovieData()})
        
    }
    
    func getMovieData() {
        API(user: user).getTopSearches() { (result) in
            switch result {
            case .success(let movies):
                DispatchQueue.main.async {
                    self.movies = movies
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

//Source: https://www.appcoda.com/swiftui-search-bar/
struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool;
    
    var body: some View {
        HStack {
            HStack {
                TextField("Search...", text: $text)
                    .padding(.leading,24)
                    
                }
                    .padding()

                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 24)
                     
                            if self.isSearching {
                                                        
                                Button(action: {self.text = ""}) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 22)
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        self.isSearching = true
                    }
                
                if self.isSearching {
                    Button(action: {
                        // Dismiss the keyboard
                        self.isSearching = false
                        self.text = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    })
                    {Text("Cancel")}
                    .padding(.trailing, 20)
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
            }
          
      }
   
}

struct MovieRow: View {
    @State var movie: Movie
    @State var isActive = false;


    
    var body: some View {
                
        NavigationLink(destination: MovieView(movie: movie), isActive: $isActive) {
            HStack {
                let m = MovieDecode(movie:movie)
                
                VStack {
                    WebImage(url: m.posterURL())
                            .resizable()
                            .renderingMode(.original)
                            .placeholder(Image("no_image"))
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                    
                }
                .frame(width: 40, height: 70)
                
                VStack(alignment: .leading) {
                    
                    Text(movie.title).font(.headline)
                    //let sub = String(movie.year) + "-" + movie.rated + "-" + movie.runtime
                    Text(m.subString()).font(.subheadline).foregroundColor(.gray)

                }
                Spacer()
                Text(m.price())
                
                Image(systemName: "chevron.right")
                     .foregroundColor(.gray)
                
            }.onTapGesture{self.isActive = true}
       }
    
    }
}

struct SearchView: View {
    
    @EnvironmentObject var user: UserData
    
    @State var text = ""
    @State var isSearching = false
    
    @StateObject var dataSource = ContentDataSource()
    @State var isActive = false;
    
    let width = (UIScreen.main.bounds.width - 33)
    
    var body: some View {
        
            VStack(spacing: 0) {
                Text("Search \(text)").font(.title).bold().frame(width:width, alignment: .leading)
                SearchBar(text: $text, isSearching: $isSearching).onChange(of: text, perform: { value in
                        dataSource.setText(text: value, user: user)
                  })
                    .frame(width: width, height: 80)
                    .onAppear{ dataSource.query = "title"}
            }
            
            VStack {
                if (!isSearching) {
                    MostSearchedView()
                }

                else {
                    ScrollView{
                            LazyVStack {
                                ForEach(dataSource.items, id: \.uuid) { movie in
                                    if(dataSource.items.last == movie){
                                        MovieRow(movie: movie)
                                            .padding(.leading,24)
                                            .padding(.trailing, 20)
                                            //.onTapGesture{self.isActive = true}
                                            .frame(width: (UIScreen.main.bounds.width - 15), height: 80)
                                            .onAppear {
                                                print("Load More")
                                                dataSource.loadMoreContent(user: user)
                                            }
                                            
                                    }
                                        
                                    else {
                                        MovieRow(movie: movie)
                                            .padding(.leading,24)
                                            .padding(.trailing, 20)
                                            .frame(width: (UIScreen.main.bounds.width), height: 80)
                                        
                                        Divider()
                                    }
                              
                                }
                                
                                if dataSource.isLoadingPage {
                                    ProgressView() //A view that shows the progress towards completion of a task.
                                }
                                
                            }

                      }
                }

            }

        .navigationBarHidden(true)
        .navigationBarTitle(Text("Search \(text)"), displayMode: .large)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
    }

}
