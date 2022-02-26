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


struct SearchMovieView: View {
    var width: CGFloat
    var height: CGFloat
    var user: UserData
    
    @State var isActive = false;
    @State var movie: Movie

    var body: some View {
        VStack {
            if let movie = movie {
                NavigationLink(destination: MovieView(movie: movie), isActive: $isActive) {
                    let m = MovieDecode(movie: movie)
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))

                            WebImage(url: m.posterURL())
                                    .resizable()
                                    .renderingMode(.original)
                                    .placeholder(Image("no_image"))
                                    //.aspectRatio(contentMode: .fit)
                                    .clipped()
                                    .cornerRadius(8)
                        
                        }.frame(width: width, height: height*0.75)
                            //.border(Color.green)


                        
                        Text(movie.title)
                            .bold()
                            .foregroundColor(Color.white)
                            .frame(width: width, height: 15, alignment: .leading)

                        Text(String(movie.year))
                            .foregroundColor(Color.gray)
                            .frame(width: width, alignment: .leading)
                        
                    }
                }
            }
            
            else {
                ProgressView()
            }
            
        }
        .frame(width: width, height: height)
    }
}


struct SimplifiedMovieView: View {
    
    var width: CGFloat
    var height: CGFloat
    var user: UserData
    var meta: MovieMeta
    
    @State var isActive = false;
    @State var movie: Movie?

    var body: some View {
        VStack {
            if let movie = movie {
                NavigationLink(destination: MovieView(movie: movie), isActive: $isActive) {
                    let m = MovieDecode(movie: movie)
                    
                    VStack {
                        WebImage(url: m.posterURL())
                                .resizable()
                                .renderingMode(.original)
                                .placeholder(Image("no_image"))
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(8)
                                .frame(width: width)
                        
                        Text(movie.title)
                            .bold()
                            .foregroundColor(Color.white)
                            .frame(width: width, height: 15, alignment: .leading)

                        Text(String(movie.year))
                            .foregroundColor(Color.gray)
                            .frame(width: width, alignment: .leading)
                        
                    }
                }
            }
            
            else {
                ProgressView()
            }
            
        }
        .frame(width: width, height: height)
        .padding(.bottom, 10)
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
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @EnvironmentObject var user: UserData
    @State var movies = [MovieMeta]()
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height


    var body: some View {
        
        ScrollView {
            VStack {
                Text("Top Searches").font(.title2).bold()
                    .frame(width:width, alignment: .leading)
                
                GeometryReader{ geo in
                    WrappingHStack(movies, id: \.self) { meta in
                        
                        VStack{
                            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                                 //let width = geo.size.width*0.25
                                 //let height = geo.size.height*0.20
                                let width = CGFloat(100)
                                let height = CGFloat(250)
                                
                                SimplifiedMovieView(width: width, height: height, user: user, meta: meta)
                                
                            }
                            else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                                //let width = geo.size.width*0.14
                                //let height = geo.size.height*0.20
                                let width = CGFloat(100)
                                let height = CGFloat(250)
                                
                                SimplifiedMovieView(width: width, height: height, user: user, meta: meta)
                                

                            }
                            else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                                //let width = geo.size.width*0.14
                                //let height = geo.size.height*0.35
                                let width = CGFloat(150)
                                let height = CGFloat(300)
                                
                                SimplifiedMovieView(width: width, height: height, user: user, meta: meta)
                            }
                        }

                   }
                }.frame(width: width, height: height ,alignment: .center)

            }
            
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
                    .padding(.leading,25)
                    //.border(Color.red)
                    
                }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    //.padding(.horizontal)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                     
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

struct SearchCastRow: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    
    @Binding var text: String
    @State var cast = [Star]()
    @State var isLoading = false
    
    let rowHeight = 65
    let width = (UIScreen.main.bounds.width-33)

    var body: some View {
        VStack {
            
            if cast.count > 0 && !isLoading {
                Text("Cast & Crew").font(.system(size: 15)).bold().frame(width:width, alignment: .leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(cast, id: \.starId) { cast in
                            let c = StarDecode(cast: cast)
                            let d = Cast(starId: cast.starId)
                            NavigationLink(destination: CastView(cast: d)) {
                                VStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color(.systemGray6))
                                            .frame(width: 100, height: 145)

                                        
                                        WebImage(url: URL(string: c.photo()))
                                                .resizable()
                                                .renderingMode(.original)
                                                .placeholder(Image(systemName: "person"))
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(8)
                                                .frame(width: 100, height: 145)

                                    }
                                    .frame(width: 100, height: 145)
                                    
                                    Text(c.name())
                                            .foregroundColor(Color.blue)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(1)

                                    /*
                                     Text(c.subStringCast())
                                         .font(.subheadline)
                                         .foregroundColor(.gray)
                                         .frame(maxWidth: .infinity, alignment: .leading)
                                         .lineLimit(1)
                                     */

                                    
                                }.frame(width: 100)
                            }
                        
                        }
                        
                    }
                    
                }
                .padding(.bottom, 5)
                .padding(.leading, 15)
                .padding(.trailing, 15)
            }
            else {
                ProgressView()
            }

        }
        .onChange(of: text, perform: { value in
                isLoading = true
                getCastSearch(name: value)
          })
        
    }
    
    func getCastSearch(name: String) {
        API(user: user).searchCast(name: name){ (result) in
            switch result {
            case .success(let cast):
                DispatchQueue.main.async {
                    self.cast = cast
                    isLoading = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.subtitle = error.localizedDescription
                    viewModel.show = true
                }
            }
        }
    }
}


struct SearchView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    
    @State var text = ""
    @State var isSearching = false
    @State var cast: [Star]?
    @StateObject var dataSource = ContentDataSource()
    @State var isActive = false;
    
    let width = (UIScreen.main.bounds.width - 33)
    let height = UIScreen.main.bounds.height
    
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
                                if horizontalSizeClass == .compact && verticalSizeClass == .regular {
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
                                    
                                else {
                                    
                                    VStack {
                                        
                                        SearchCastRow(text: $text)
                                        
                                        VStack {
                                            Text("Movies").font(.headline).bold().frame(width:width, alignment: .leading)
                        
                                            GeometryReader{ geo in
                                                WrappingHStack(dataSource.items, id: \.self) { movie in
                                                    
                                                    VStack {
                                                        let width = CGFloat(150)
                                                        let height = CGFloat(300)
                                                        

                                                        SearchMovieView(width: width, height: height, user: user, movie: movie)
                                                            
                                                    }

                                               }
                                                
                                            }
                                            .frame(width: width, height: CGFloat(dataSource.items.count/6 * 300 ), alignment: .center)
                                            
                                            if dataSource.isLoadingPage {
                                                ProgressView() //A view that shows the progress towards completion of a task.
                                            }

                                        }
                                        
                                    }

                                }
                            }
                      }.frame(height: height)
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
