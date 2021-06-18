//
//  CartView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/29/21.
//

import SwiftUI
import CoreData
import UIKit
import URLImage
import SDWebImageSwiftUI
import Combine


struct iPhoneCartView: View {
    @EnvironmentObject var user: User

    let width = (UIScreen.main.bounds.width - 33)
    var body: some View {
        VStack {
            
            ForEach(Array(user.cart.keys), id: \.id) { movie in
                VStack {
                    let m = MovieDecode(movie: movie)

                    HStack {
                            HStack{
                                Button(action: {
                                    print("Remove button pressed...")
                                    user.removeFromCart(movie: movie)
                                })
                                {
                                  
                                    Image(systemName: "minus")
                                        .font(.title)
                                        .foregroundColor(.red)
                                    
                                }.buttonStyle(BorderlessButtonStyle())

                            }

                      
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
                                //Divider()
                                Image(systemName: "chevron.right.square")
                                    .font(Font.system(size: 30))
                                
                            }
                        }
                    }
                    
                    HStack(alignment: .center) {
                        
                        HStack{
                            Button(action: {
                                print("Qty - button was tapped")
                                user.decrementQty(movie: movie)

                     
                            }) {
                                Image(systemName: "minus")
                            }.buttonStyle(BorderlessButtonStyle())

                            
                            Text("Qty: \(user.cart[movie]!)")
                            
                            Button(action: {
                                print("Qty + button was tapped")
                                user.incrementQty(movie: movie)
                                
                            }) {
                                Image(systemName: "plus")
                            }.buttonStyle(BorderlessButtonStyle())


                        }
                                          
                        Divider().frame(maxWidth: 50)
                        
                        
                        Text("\(m.price())")
                        
                    }.frame(width: width, height: 40, alignment: .trailing)
                    
                    Divider().frame(maxWidth:width)
                
                }
                
            }.frame(width: width)
            
        }
        
    }
}

struct iPadCartView: View {
    @EnvironmentObject var user: User

    let width = (UIScreen.main.bounds.width - 33)
    var body: some View {
        VStack {
            ForEach(Array(user.cart.keys), id: \.id) { movie in
                VStack {
                    let m = MovieDecode(movie: movie)
                    
                    HStack {
                        HStack{
                            Button(action: {
                                print("Remove button pressed...")
                                user.removeFromCart(movie: movie)
                            })
                            {
                              
                                Image(systemName: "minus")
                                    .font(.title)
                                    .foregroundColor(.red)
                                
                            }.buttonStyle(BorderlessButtonStyle())

                        }
                      
                            HStack {
                                
                                NavigationLink(destination: MovieView(movie: m.movie)) {

                                VStack {
                                    WebImage(url: URL(string: m.poster()))
                                            .resizable()
                                            .renderingMode(.original)
                                            .placeholder(Image("no_photo"))
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(8)
                                    
                                }.frame(width: 40, height: 70)
                                
                                VStack(alignment: .leading) {
                                    
                                    Text(m.title()).font(.headline)
                                    Text(m.subString()).font(.subheadline).foregroundColor(.gray)

                                }
                                
                                Spacer()
                                Divider()
                                    
                                }
                                
                                VStack(alignment: .center) {
                                                            
                                    Text("\(m.price())")
                                    
                                    Divider().frame(maxWidth: 110)
                                    
                                    HStack{
                                        Button(action: {
                                            print("Qty - button was tapped")
                                            user.decrementQty(movie: movie)

                                 
                                        }) {
                                            Image(systemName: "minus")
                                        }.buttonStyle(BorderlessButtonStyle())

                                        
                                        Text("Qty: \(user.cart[movie]!)")
                                        
                                        Button(action: {
                                            print("Qty + button was tapped")
                                            user.incrementQty(movie: movie)
                                            
                                        }) {
                                            Image(systemName: "plus")
                                        }.buttonStyle(BorderlessButtonStyle())


                                    }
                                                      
                                }.frame(width: 120)
                                
                            }
                        
                    }
                
                }
                
                Divider().frame(width: (UIScreen.main.bounds.width - 33))
                
            }.frame(width: (UIScreen.main.bounds.width - 33))
            
        }
      
    }
    
}

struct CartView: View {
    @EnvironmentObject var user: User
    let width = (UIScreen.main.bounds.width - 33)

    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false

    var body: some View {
        VStack {
            Text("My Cart").font(.title).bold().frame(width:width, alignment: .leading)

            if(user.cart.count == 0) {
                GeometryReader {geometry in

                    VStack {
                        Image(systemName: "cart")
                            .font(.system(size: 56.0))
                            .foregroundColor(.gray)

                        Text("There are not items in your Cart.")
                            .fontWeight(.semibold)
                            .font(.system(size: 15.0))
                            .foregroundColor(.gray)

                    }.offset( x:(geometry.size.width/2)-120, y: (geometry.size.height/2)-120)
                
                }
                
            }
            
            else {
                Text("Subtotal: \(user.calc_subTotal())").font(.headline).bold().padding(.bottom,5)
                    .frame(width: width, alignment: .leading)
                
                VStack {
                    
                    Button(action: {
                        print("checkout")
                    }) {
                        Text("Checkout").bold()
                            //.frame(width: 200 , height: 50, alignment: .center)
                            //You need to change height & width as per your requirement
                    }
                    .frame(width: width, height: 50)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                }.frame(width: width, height: 50)
                
                ScrollView {
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                
                        iPadCartView()

                    }
                
                    else {
                        
                        iPhoneCartView()

                    }
                }.frame(width: UIScreen.main.bounds.width)
          
            }
            
        }.offset(y: 15)
        
        .navigationBarHidden(true)
        .navigationBarTitle(Text("My Cart"), displayMode: .large)

        
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

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
