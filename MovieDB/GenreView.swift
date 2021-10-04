//
//  GenreView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/19/21.
//

import SwiftUI
import URLImage
import AlertToast

struct GenreView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    var genre: Genre
    
    @State var movies = [Movie]()
    @State var qty = 0
    
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
                                dataSource.loadMoreContent(user: user)
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
                dataSource.setText(text: genre.name, user: user)
                self.getCartQtyData()
                
            }
            
        
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
