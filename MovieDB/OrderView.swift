//
//  OrderView.swift
//  MovieDB
//
//

import SwiftUI
import CoreData
import UIKit
import URLImage
import SDWebImageSwiftUI
import Combine


struct OrderDetailsView: View {
    @EnvironmentObject var user: User
    @State var sale: Sale
    @State var movies = [String : Movie]()
    
    @State var total = "0.0"

    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    
    let width = (UIScreen.main.bounds.width - 33)
    let height = (UIScreen.main.bounds.height - 33)

    var body: some View {

        VStack{
            
            Text("Subtotal: \(calc_subtotal())").font(.system(size: 15)).bold().frame(width:width, alignment: .trailing)
            
            //Text("Sales Tax: 0.00%").font(.system(size: 15)).bold()
            
            Text("Shipping: $0.00").font(.system(size: 15)).bold().frame(width:width, alignment: .trailing)
            
            Text("Total: \(calc_subtotal())").font(.system(size: 25)).bold().frame(width:width, alignment: .trailing)
            
            Divider()

    
            List(sale.orders, id: \.id) { order in
                let m = MovieDecode(movie: movies[order.movieId] ?? Movie())

                NavigationLink(destination: MovieView(movie: m.movie)) {
                    HStack {
                        VStack {
                            WebImage(url: URL(string: m.poster()))
                                    .resizable()
                                    .renderingMode(.original)
                                    .placeholder(Image("no_image"))
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                            
                        }.frame(width: 40, height: 70)
                        
                        VStack(alignment: .leading) {
                            
                            Text(m.title()).font(.headline)
                            Text(m.subString()).font(.subheadline).foregroundColor(.gray)

                        }
                        
                        Spacer()
                        Divider()
                        
                        VStack(alignment: .center) {
                            Text("Qty: \(order.quantity)")
                            Divider().frame(maxWidth: 80)
                            Text("\(m.price(f: order.list_price))")
                        }.frame(width: 80)
                        
                    }.onAppear{loadMovie(id: order.movieId)}
                    
             }
                
            }.frame(width: width)
            
            //Spacer()
            
            //.frame(width: width, height: (CGFloat(sale.orders.count) * 90))
            
            
        }.offset(y: 15)
        
        .navigationBarHidden(false)
        .navigationBarTitle(Text("Order #" + String(sale.id)), displayMode: .large)
        
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
    
    func calc_subtotal() -> String{
        let total = sale.orders.reduce(0) {$0 + ($1.list_price * Double($1.quantity))}

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: total))!
        
    }
    
    func loadMovies() {
        for order in sale.orders {
            loadMovie(id: order.movieId)
        }
    }
    
    
    func loadMovie(id: String) {
                
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
                        self.movies[id] = decodedResponse
                    }
                    // everything is good, so we can exit
                    return
                }
            }
        
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
}

struct OrderView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var movie_api: MovieDB_API

    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    let width = (UIScreen.main.bounds.width - 33)

    
    
    var body: some View {
        
        VStack {
        
        Text("My Orders").font(.title).bold().frame(width:width, alignment: .leading)

            if(user.data.sales.count == 0) {
                GeometryReader {geometry in

                    VStack {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 56.0))
                            .foregroundColor(.gray)

                        Text("There are no orders your account.")
                            .fontWeight(.semibold)
                            .font(.system(size: 15.0))
                            .foregroundColor(.gray)

                    }.offset( x:(geometry.size.width/2)-120, y: (geometry.size.height/2)-120)
                
                }
                
            }
            
            else {
                
                ScrollView {
                    LazyVStack{
                        ForEach(user.data.sales, id: \.id) { sale in
                            let sale_decode = SaleDecode(sale: sale)
                                
                            NavigationLink(destination: OrderDetailsView(sale: sale)) {
                                VStack {
                                    
                                    HStack {
                                        
                                        VStack(alignment: .leading) {
                                            Text(sale_decode.getId()).bold()
                                            Text("Number of Items: \(sale_decode.getNumItems())")
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: . trailing){
                                            
                                            Text(sale.saleDate)
                                            Text("Total: \(sale_decode.getTotal())")
                                        }
           
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                        
                                    }
                                    
        
                                }

                            }//.buttonStyle(PlainButtonStyle())
                            
                            Divider().frame(width: width)


                        }
                        
                    }.frame(width: width)
                    
                }.frame(width: UIScreen.main.bounds.width)
            
            }
            
        }.offset(y: 15)
        
        .navigationBarHidden(true)
        .navigationBarTitle(Text("Orders"), displayMode: .large)
        
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

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView()
    }
}
