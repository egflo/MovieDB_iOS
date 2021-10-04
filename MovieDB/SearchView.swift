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
    @State var qty = 0
    
    @StateObject var dataSource = ContentDataSource()
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false

    @State var isActive = false;
    
    let width = (UIScreen.main.bounds.width - 33)
    
    var body: some View {
        
            VStack{
                VStack(spacing: 0) {
                    Text("Search \(text)").font(.title).bold().frame(width:width, alignment: .leading)
                    SearchBar(text: $text, isSearching: $isSearching).onChange(of: text, perform: { value in
                            dataSource.setText(text: value, user: user)
                      })
                        .frame(width: (UIScreen.main.bounds.width - 15), height: 80)
                        .onAppear{ dataSource.query = "title"}
                }
                
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
            .offset(y: 15)
            .onAppear(perform: {self.getCartQtyData()})
        
            .navigationBarHidden(true)
            .navigationBarTitle(Text("Search \(text)"), displayMode: .large)

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
