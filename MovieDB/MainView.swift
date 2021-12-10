//
//  MainView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/30/21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}

struct GenreMainRow: View {
    var genre: MovieMeta
    @State var isActive = false

    var body: some View {
        
        //let genre_data = Genre(id: genre.id!, genreId: genre.id!, name: genre.name!)
        let genre_data = Genre(id: genre.id!, name: genre.name!)
        ZStack{
            Image("background")
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .clipped()
                .cornerRadius(8)
                .frame(width: 200, height: 100)

            
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.random)
                .frame(width: 200, height: 100)
                .opacity(0.6)

            Text(genre.name!).font(.system(size: 30)).bold().foregroundColor(.white).shadow(radius: 5)
            
        }
        .onTapGesture {
            self.isActive = true
        }
        .frame(height: 100)
        .background(
             NavigationLink(destination: GenreView(genre: genre_data), isActive: $isActive) {
                EmptyView()
            }
       )
    }
    
}

struct GenreMain: View {
    @EnvironmentObject var user: UserData

    var path: String
    @State private var genres = [MovieMeta]()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack (spacing: 10) {
                ForEach(genres, id: \.id) { genre in
                    
                    GenreMainRow(genre: genre)
                    
                }
            }
            
        }.onAppear{getGenresData()}
    }
    
    
    func getGenresData() {
        API(user: user).getMetaMovie(path: path) {(result) in
            switch result {
            case .success(let genres):
                DispatchQueue.main.async {
                    self.genres = genres
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}


struct MovieRowView: View {
    @EnvironmentObject var user: UserData

    var meta: MovieMeta
    @State var isActive = false;
    @State var movie: Movie?
    
    var body: some View {
        
        VStack{
            if let movie = movie {
                let m = MovieDecode(movie:movie)

                NavigationLink(destination: MovieView(movie: movie), isActive: $isActive){
                    ZStack (alignment: .bottomLeading){
                            WebImage(url: URL(string: m.background()))
                                    .resizable()
                                    .placeholder(
                                        Image("background")
                                    )
                                    .scaledToFill()
                                    .clipped()
                                    .transition(.fade(duration: 0.5)) // Fade Transition with duration
                            
                            VStack(alignment: .leading) {
                                Text(m.title()).font(.system(size: 28)).bold().foregroundColor(.white).shadow(radius: 5)
                                    .padding(.trailing, 4)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)

                                Text(m.subString()).font(.subheadline).bold().foregroundColor(.white).shadow(radius: 5)

                            }
                            .padding(.bottom,20)
                            .padding(.leading,20)
                    }
                    
                }
                .onTapGesture{self.isActive = true}
            }
            
            else {
                ProgressView()
            }


        }
        .cornerRadius(8)
        .onAppear(perform: {
            self.getMovieData()
        })
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

struct MovieMainView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @StateObject var dataSource = ContentDataSourceMain()

    @State var metas = [MovieMeta]()

    let title: String
    let path: String
    let width = (UIScreen.main.bounds.width)


    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        /* Disabled for IPhone (Portrait Mode Only)*/
        VStack {
            if(dataSource.items.count != 0) {
                Text(title).font(.title).bold()
                    .frame(width: width, alignment:.leading)
                
                ScrollView(.horizontal, showsIndicators: false){

                    LazyHStack (spacing: 10){
                        ForEach(dataSource.items, id: \.uuid) { meta in
                            
                            if(dataSource.items.last! == meta){
                                
                                VStack {
                                    
                                    if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                                            MovieRowView(meta: meta)
                                                .frame(width: 330, height: 180, alignment: .center)
                                        

                                    }
                                    else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                                        
                                            MovieRowView(meta: meta)
                                                .frame(width: 400, height: 220, alignment: .center)
                                        

                                    }
                                    else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                                        
                                            MovieRowView(meta: meta)
                                                .frame(width: 400, height: 220, alignment: .center)
                                        
                                    }
                                    
                                }.onAppear {
                                    print("Load More")
                                    dataSource.loadMoreContent(user: user, path: path)
                                }


                            }
                            else {
                                
                                if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                                        MovieRowView(meta: meta)
                                            .frame(width: 330, height: 180, alignment: .center)
                                    

                                }
                                else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                                    
                                        MovieRowView(meta: meta)
                                            .frame(width: 400, height: 220, alignment: .center)
                                    

                                }
                                else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                                    
                                        MovieRowView(meta: meta)
                                            .frame(width: 400, height: 220, alignment: .center)
                                    

                                }
                                
                            }

                        
                        }

                        if dataSource.isLoadingPage {
                            ProgressView() //A view that shows the progress towards completion of a task.
                        }
                        
                    }
                    
                }
                
            }
            
        }.padding(.leading, 20)
        .onAppear {
            print("Initial Load")
            dataSource.loadMoreContent(user: user, path: path)
        }
    }
}

struct MainView: View {
    init() {
        //Use this if NavigationBarTitle is with Large Font
        //UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.red]

        //Use this if NavigationBarTitle is with displayMode = .inline
        //UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.red]
        
        UIToolbar.appearance().isTranslucent = false
        //UIToolbar.appearance().barTintColor = UIColor.systemGray6
        //UIToolbar.appearance().setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        //UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    var body: some View {
        
        ScrollView
        {
            //MovieMainView(title: "Your Watchlist", path: "/bookmark/?limit=\(5)")
            MovieMainView(title: "Your Watchlist", path: "bookmark/")
            
            //MovieMainView(title: "Top Sellers", path: "/order/sellers?limit=\(5)"
            MovieMainView(title: "Top Sellers", path: "order/sellers")
           
           //MovieMainView(title: "Top Rated", path:"/rating/rated?limit=\(5)")
            MovieMainView(title: "Top Rated", path: "rating/rated")
                        
            Text("Genres").font(.title).bold().padding(.leading,15).frame(width: UIScreen.main.bounds.width, alignment:.leading)

            GenreMain(path: "/genre/all?limit=25")
                .padding(.leading,15)
                .padding(.bottom, 15)
            
        }
        
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
    
    }
}

