//
//  GenreView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/19/21.
//

import Foundation
import SwiftUI
import URLImage


struct GenreView: View {
    @EnvironmentObject var user: User

    @State var genre: Genre
    @State var movies = [Movie]()

    @StateObject var dataSource = ContentDataSource()
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false

    var body: some View {
            
        ScrollView{
            LazyVStack {
                ForEach(dataSource.items, id: \.id) { movie in
                    if(dataSource.items.last == movie){
                        MovieRow(movie: movie)
                            .frame(width: (UIScreen.main.bounds.width - 33), height: 80)
                            .onAppear {
                                dataSource.loadMoreContent()
                            }
                    }
                    else {
                        MovieRow(movie: movie)
                            .frame(width: (UIScreen.main.bounds.width - 33), height: 80)
                        
                        Divider()
                    }
                    
                }
                
                .navigationBarTitle("\(genre.name)")
                
            } .onAppear {
                dataSource.query = "genre"
                dataSource.setText(text: String(genre.genreId))}
        
            if dataSource.isLoadingPage {
                ProgressView() //A view that shows the progress towards completion of a task.
            }
            
       }
        
        .navigationBarHidden(false)
        .navigationBarTitle(Text("\(genre.name)"), displayMode: .large)
        

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
