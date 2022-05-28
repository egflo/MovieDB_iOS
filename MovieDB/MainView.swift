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
    var genre:Genre
    @State var isActive = false

    var body: some View {
        
        //let genre_data = Genre(id: genre.id!, genreId: genre.id!, name: genre.name!)
        let genre_data = Genre(id: genre.id, name: genre.name)
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

            Text(genre.name).font(.system(size: 30)).bold().foregroundColor(.white).shadow(radius: 5)
            
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
    @State private var genres = [Genre]()

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
        let URL = "\(MyVariables.API_IP)\(path)"
        
        NetworkManager.shared.getRequest(of: [Genre].self, url: URL) {(result) in
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
            
            let m = MovieDecode(movie: meta.movie!)

            NavigationLink(destination: MovieView(movieId: meta.movieId!), isActive: $isActive){
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
        .cornerRadius(8)
    }
     
}

struct MovieMainView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @StateObject var dataSource = ContentDataSourceTest<MovieMeta>()
    @State var metas = [MovieMeta]()
    var title: String
    var path: String

    @State var height: CGFloat = 180
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    

    var body: some View {
        /* Disabled for IPhone (Portrait Mode Only)*/
        
        VStack {
            if(dataSource.isLoadingPage) {
                
                ProgressView()
            }
            
            if(dataSource.items.count != 0) {
                HStack {
                    Text(title).font(.title).bold()
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false){

                    LazyHStack (spacing: 10){
                        ForEach(dataSource.items, id: \.uuid) { meta in
                            
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
                            
                                
                            }

                            .onAppear(perform: {
                                if !self.dataSource.endOfList {
                                    if self.dataSource.shouldLoadMore(item: meta) {
                                        self.dataSource.fetch(path: path)
                                    }
                                }
                            })
                        
                        }

                    }
                    
                }
                
            }
            
        }
        .padding(.leading, 20)
        .onAppear {
            dataSource.fetch(path: path)
        }
        
    }
            
    
}

struct MainView: View {
    init() {
        //Use this if NavigationBarTitle is with Large Font
        //UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.red]

        //Use this if NavigationBarTitle is with displayMode = .inline
        //UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.red]
        
        
        /*
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = .systemPink
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
               
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        */
        
        
        if #available(iOS 15, *) {
            let appear = UIToolbarAppearance()
            appear.configureWithDefaultBackground()
            appear.shadowImage = UIImage()
            appear.backgroundImage =
            UIImage()
                .sd_blurredImage(withRadius: 20)
                
            //appear.backgroundColor = .systemGray6
            
            
            //UIToolbar.appearance().setBackgroundImage(UIImage(),
            //                                forToolbarPosition: .any,
            //                                barMetrics: .default)
            //UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
            
            UIToolbar.appearance().standardAppearance = appear
            UIToolbar.appearance().compactAppearance = appear
            UIToolbar.appearance().scrollEdgeAppearance = appear
            UIToolbar.appearance().isTranslucent = true
            
            let tb = UIToolbar()
            tb.isTranslucent = true
            tb.sizeToFit()

        }
        


        
        //UIToolbar.appearance().isTranslucent = false
        //UIToolbar.appearance().barTintColor = UIColor.systemGray6
        //UIToolbar.appearance().setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        //UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    var body: some View {
        
        GeometryReader {geo in

            ScrollView
            {

                MovieMainView(title: "Your Watchlist", path: "bookmark/all")
                
                MovieMainView(title: "Top Rated", path: "rating/rated")
                
                MovieMainView(title: "Top Sellers", path: "order/sellers")
               
                            
            //Text("Genres").font(.title).bold().padding(.leading,15).frame(width: UIScreen.main.bounds.width, alignment:.leading)

                GenreMain(path: "/genre/all?limit=25")
                    .padding(.leading,15)
                    .padding(.bottom, 15)
                
            }
            
        }
        

        .navigationBarHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
    
    }
}

