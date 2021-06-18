//
//  CastView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/16/21.
//

import Foundation
import SwiftUI
import URLImage
import SDWebImageSwiftUI

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
    @Binding var cast: Cast
    @State var movies = [Movie]()
    
    @EnvironmentObject var movie_api: MovieDB_API

    
    var body: some View {
        
            
        VStack { //geometry in

            List {
                    Section(header:
                        VStack(alignment: .center) {
                            Text("Cast & Crew")
                                .font(.subheadline).bold()
                                .foregroundColor(Color.blue)
                                .textCase(.none)

                        })
                    {
                    
                    ForEach(movies, id: \.uuid) { movie in
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
                                    Text(m.subString()).font(.subheadline).foregroundColor(.gray)


                                }
                                Spacer()
                                Text("Details")
                            }
                        }

                    }

                }//.frame(width: (geometry.size.width) - 33)//.background(Color.blue)


            }
            .listStyle(GroupedListStyle())

            .onAppear(perform: {
                self.loadMoviesByCast(id: cast.starId)
                UITableView.appearance().isScrollEnabled = false
            })
            
        }.frame(height: (UIScreen.main.bounds.height - 33))
    }
    
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

}

struct iPhoneCastView: View {
    @Binding var cast: Cast
    
    var body: some View {
        let c = CastDecode(cast: cast)
        
        VStack {

            WebImage(url: URL(string: c.photo()))
                .resizable()
                .renderingMode(.original)
                .placeholder(Image("no_image"))
                .aspectRatio(contentMode: .fit)
                .cornerRadius(8)
    
        }.frame(width: (UIScreen.main.bounds.width - 33), height: 250)
        
        Text(cast.name).font(.title)
    
        Text(c.subString()).font(.subheadline).foregroundColor(.gray)//.padding(.bottom,10)
 
        Text(c.birthDetails()).padding(.bottom,5).frame(width: (UIScreen.main.bounds.width - 33), height: 70)
    
        DropDown(headline: "Biography", text: c.bio())//.padding(.bottom,10)
    
        //CastMovieRow(cast: cast).frame(width: (UIScreen.main.bounds.width - 33), height: 175)
        
    }
}

struct iPadCastView: View {
    @Binding var cast: Cast
    
    var body: some View {
        let c = CastDecode(cast: cast)

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
                //.border(Color.red)
            
            ScrollView {
                VStack(alignment: .leading){
                    
                    HStack {
                        Text("\(c.name()) \(c.subString())")
                            .font(.system(size: 30.0))
                            .bold()
            
                        
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
                        //.frame(width: (UIScreen.main.bounds.width-300), alignment: .leading)


                    
                }.frame(width: (UIScreen.main.bounds.width-350), alignment: .leading)//.border(Color.red)
                
            }
            
        }.frame(width: (UIScreen.main.bounds.width-33), height: 400)//.border(Color.blue)
    }
}

struct CastView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var movie_api: MovieDB_API

    @State var cast: Cast
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    var body: some View {
        VStack {
            ScrollView{
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    
                        iPadCastView(cast: $cast)
                        CastMovieRow(cast: $cast)
            

                }
                else {

                        iPhoneCastView(cast: $cast)
                        CastMovieRow(cast: $cast)
                        //CastMovieRow(cast: cast).frame(width: (UIScreen.main.bounds.width - 33), height: 175)
                        
                
                }
            }
            
        }
        .onAppear{self.loadCast(id: cast.starId)}
       
        .navigationBarHidden(false)
        .navigationBarTitle(Text("\(cast.name)"), displayMode: .inline)

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
}
