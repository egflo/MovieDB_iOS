//
//  CastView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/16/21.
//

import SwiftUI
import URLImage
import SDWebImageSwiftUI
import AlertToast

struct DropDown: View {
    var headline: String
    var text: String

    @State var expand = false

    var body: some View {
        
        VStack(alignment: .leading, content: {
            
            HStack {
                Text(headline).font(.subheadline).bold()
                
                Image(systemName: expand ? "chevron.up" : "chevron.down")
                    .font(.system(size: 20))
            }
            .onTapGesture {
                self.expand.toggle()
            }
        })
        .frame(width: (UIScreen.main.bounds.width), height: 40)
        .background(Color(.systemGray6))
        .foregroundColor(Color.blue)

        
        if expand {
            Text(self.text)
                .padding(.bottom, 5)
                .frame(width: (UIScreen.main.bounds.width - 50), alignment: .topLeading)
            
        }
    }
    
}

struct CastMovieRow: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @Binding var cast: Cast
    @State var movies: [Movie]?
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Filmography").font(.subheadline).bold()
            }
            .frame(width: (UIScreen.main.bounds.width), height: 40)
            .background(Color(.systemGray6))
            .foregroundColor(Color.blue)
            
            if let movies = movies {
                
                List(movies, id: \.uuid) { movie in
                    let m = MovieDecode(movie:movie)

                    NavigationLink(destination: MovieView(movie: movie)) {
                        HStack {
                            VStack {
                                WebImage(url: URL(string: m.poster()))
                                        .resizable()
                                        .renderingMode(.original)
                                        .placeholder(Image("no_image"))
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(8)
                                
                            }
                            .frame(width: 30, height: 60)
                            
                            VStack(alignment: .leading) {
                                
                                Text(m.title())
                                    .foregroundColor(Color.blue)

                                Text(m.subString()).font(.subheadline).foregroundColor(.gray)


                            }
                            Spacer()
                            Text("Details")
                                .foregroundColor(Color.blue)

                        }
                    }

                }
                .frame(height: UIScreen.main.bounds.height)
                //.listStyle(GroupedListStyle())
                .listStyle(PlainListStyle())

                .onAppear(perform: {
                    UITableView.appearance().isScrollEnabled = false
                })
                
                .frame(height: (UIScreen.main.bounds.height))
                
            }
            
            else {
                ProgressView()
                Spacer()
            }

        }
        .onAppear(perform: {self.getStarMovieData()})

    }
    
    func getStarMovieData() {
        API(user: user).getMovies(path: "/movie/star/\(cast.starId)?limit=50") { (result) in
            switch result {
            case .success(let movies):
                DispatchQueue.main.async {
                    self.movies = movies
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }
}

struct iPhoneCastView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @Binding var cast: Cast
    @State var star: Star?

    var body: some View {
        VStack {
            
            if let star = star {
                
                let c = StarDecode(cast: star)
                
                VStack {

                    WebImage(url: URL(string: c.photo()))
                        .resizable()
                        .renderingMode(.original)
                        .placeholder(Image("no_image"))
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
            
                }.frame(width: (UIScreen.main.bounds.width - 33), height: 250)
                
                Text(c.name()).font(.title).bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            
                Text(c.subString()).font(.subheadline).foregroundColor(.gray)//.padding(.bottom,10)
         
                Text(c.birthDetails()).padding(.bottom,5).frame(width: (UIScreen.main.bounds.width - 33), height: 70)
            
                DropDown(headline: "Biography", text: c.bio())//.padding(.bottom,10)
                
            }
            
            else {
                ProgressView()
            }

        }
        
        .onAppear{self.getStarData()}
            
    }
    
    func getStarData() {
        API(user: user).getCast(id: cast.starId) { (result) in
            switch result {
            case .success(let star):
                DispatchQueue.main.async {
                    self.star = star
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }
}

struct iPadCastView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @Binding var cast: Cast
    @State var star: Star?

    var body: some View {
        
        VStack {
            
            if let star = star {
                
                let c = StarDecode(cast: star)

                HStack(alignment: .top){
                    WebImage(url: URL(string: c.photo()))
                        .resizable()
                        //.renderingMode(.original)
                        .placeholder(Image("no_image"))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 290, height: 400)
                        .clipped()
                        //.aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                    
                    ScrollView {
                        VStack(alignment: .leading){
                            
                            HStack {
                                Text("\(c.name()) \(c.subString())")
                                    .font(.system(size: 30.0)).bold()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                    
                                
                            }.padding(.bottom,5)

                            let birth_details = c.birthDetails()
                            
                            if(birth_details.count != 0) {
                                
                                Text(c.birthDetails())
                                    .font(.system(size: 20.0))
                                    .foregroundColor(.gray)
                                    .padding(.bottom,5)
                                
                            }

                            Text(c.bio())
                                .font(.system(size: 20.0))
                                .foregroundColor(.gray)
                                .padding(.bottom,5)


                            
                        }.frame(width: (UIScreen.main.bounds.width-350), alignment: .leading)
                        
                    }
                    
                }.frame(width: (UIScreen.main.bounds.width-33), height: 400)
                    .padding(.bottom, 5)
                
                
            }
            
            else {
                ProgressView()
            }
            
        }
        .onAppear{self.getStarData()}
        
    }
    
    func getStarData() {
        API(user: user).getCast(id: cast.starId) { (result) in
            switch result {
            case .success(let star):
                DispatchQueue.main.async {
                    self.star = star
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }
}

struct CastView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var api: API
    @EnvironmentObject var viewModel: AlertViewModel

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @State var cast: Cast
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    @State var qty = 0
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
              if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                  iPhoneCastView(cast: $cast)
                   CastMovieRow(cast: $cast)

              }
              else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                  
                  iPhoneCastView(cast: $cast)
                   CastMovieRow(cast: $cast)
              }
              else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                  
                  iPadCastView(cast: $cast)
                  CastMovieRow(cast: $cast)

              }
              
          }
            
        }
        .onAppear(perform: {self.getCartQtyData()})
        .toast(isPresenting: $viewModel.show){

            //Choose .hud to toast alert from the top of the screen
            AlertToast(displayMode: .hud, type: .error(Color.red), title: viewModel.title, subTitle: viewModel.subtitle)

        }
        .navigationBarHidden(false)
        .navigationBarTitle(Text("\(cast.name!)"), displayMode: .inline)

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
                    ZStack {
                        Image(systemName: "cart").imageScale(.large)
                        
                        if(self.qty > 0) {
                            Text("\(self.qty)")
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
    
    func getCartQtyData() {
        API(user: user).getCartQty(){ (result) in
            switch result {
            case .success(let qty):
                DispatchQueue.main.async {
                    self.qty = qty
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}
