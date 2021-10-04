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
import AlertToast

class AlertViewModel: ObservableObject{
    
    @Published var show = false
    @Published var title = "Error"
    @Published var subtitle = "Subtitle"
    
    func setSubtitle(subtitle: String) {
        self.subtitle = subtitle
    }
    
    
    /*
    @Published var alertToast: AlertToast {
        didSet{
            show.toggle()
        }
    }
    */
}


struct iPhoneCartView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @Binding var cart: [Cart]?
    @Binding var qty: Int

    let width = (UIScreen.main.bounds.width - 33)
    var body: some View {
        VStack {
            ForEach(cart!, id: \.id) { item in
                VStack {
                    let m = MovieDecode(movie: item.movie!)

                    HStack {
                            HStack{
                                Button(action: {
                                    print("Remove button pressed...")
                                    deleteCartData(cartId: item.id)
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
                                updateCartData(cartId: item.id, qty: item.quantity - 1)
                     
                            }) {
                                Image(systemName: "minus")
                            }.buttonStyle(BorderlessButtonStyle())

                            
                            Text("Qty: \(item.quantity)")
                            
                            Button(action: {
                                print("Qty + button was tapped")
                                updateCartData(cartId: item.id, qty: item.quantity + 1)

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
    
    func deleteCartData(cartId: Int) {
        API(user: user).deleteCart(cartId: cartId){ (result) in
            switch result {
            case .success(let item):
                DispatchQueue.main.async {
                    
                    if let index = self.cart!.firstIndex(where: {$0.id == item.id}) {
                        cart!.remove(at: index)
                    }
                    getCartQtyData()
   
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
            }
        }
    }
    
    func updateCartData(cartId: Int, qty: Int) {
        API(user: user).updateCart(cartId: cartId, qty: qty) { (result) in
            switch result {
            case .success(let item):
                DispatchQueue.main.async {
                    
                    if let index = self.cart!.firstIndex(where: {$0.id == item.id}) {
                        cart![index].quantity = item.quantity
                    }
                    getCartQtyData()
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true            }
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
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true            }
        }
    }
    
}





struct iPadCartView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @Binding var cart: [Cart]?
    @Binding var qty: Int

    let width = (UIScreen.main.bounds.width - 33)
    
    var body: some View {
        VStack {
            ForEach(cart!, id: \.id) { item in
                VStack {
                    let m = MovieDecode(movie: item.movie!)
                    
                    HStack {
                        HStack{
                            Button(action: {
                                print("Remove button pressed...")
                                self.deleteCartData(cartId: item.id)
                                self.getCartQtyData()

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
                                            updateCartData(cartId: item.id, qty: item.quantity - 1)

                                        }) {
                                            Image(systemName: "minus")
                                        }.buttonStyle(BorderlessButtonStyle())

                                        
                                        Text("Qty: \(item.quantity)")
                                        
                                        Button(action: {
                                            print("Qty + button was tapped")
                                            updateCartData(cartId: item.id, qty: item.quantity + 1)
                                            
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
    
    func deleteCartData(cartId: Int) {
        API(user: user).deleteCart(cartId: cartId){ (result) in
            switch result {
            case .success(let item):
                DispatchQueue.main.async {
                    
                    if let index = self.cart!.firstIndex(where: {$0.id == item.id}) {
                        cart!.remove(at: index)
                    }
                    getCartQtyData()
   
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }
    
    func updateCartData(cartId: Int, qty: Int) {
        API(user: user).updateCart(cartId: cartId, qty: qty) { (result) in
            switch result {
            case .success(let item):
                DispatchQueue.main.async {
                    
                    if let index = self.cart!.firstIndex(where: {$0.id == item.id}) {
                        cart![index].quantity = item.quantity
                    }
                    getCartQtyData()
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
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
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }
}



/*
    PARENT VIEW
 */

//https://developer.apple.com/documentation/swift/array
struct CartView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    
    let width = (UIScreen.main.bounds.width - 33)

    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false

    @State var CheckOutActive = false
    @State var cart:[Cart]?
    @State var qty = 0
    
    var body: some View {
        VStack {
            Text("My Cart").font(.title).bold().frame(width:width, alignment: .leading)

            if let cart = cart {
                
                if(cart.count == 0) {
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
                    Text("Subtotal: \(self.calc_subTotal())").font(.headline).bold().padding(.bottom,5)
                        .frame(width: width, alignment: .leading)
                    
                    VStack {
                        
                        Button(action: {
                            print("checkout")
                            self.CheckOutActive = true
                        }) {
                            VStack {
                                Text("Checkout").bold()
                            }
                            .frame(width: width, height: 50)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }

                    
                    }
                        .frame(width: width, height: 50)
                        .background(
                            NavigationLink(destination:CheckoutView(),isActive: $CheckOutActive) {EmptyView()}
                        )
                    
                    ScrollView (showsIndicators: false){
                        
                        if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                            iPhoneCartView(cart: $cart, qty: $qty)

                        }
                        else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                            
                            iPhoneCartView(cart: $cart, qty: $qty)


                        }
                        else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                            
                            iPadCartView(cart: $cart, qty: $qty)


                        }

                    }
                    .frame(width: UIScreen.main.bounds.width)
              
                }
                
            }
            
            else {
                
                ProgressView()
            }

            Spacer()
        }
        .onAppear(perform: {
            self.getCartData()
            self.getCartQtyData()
        })
        
        .toast(isPresenting: $viewModel.show){

            //Choose .hud to toast alert from the top of the screen
            AlertToast(displayMode: .hud, type: .error(Color.red), title: viewModel.title, subTitle: viewModel.subtitle)

        }
        
        .offset(y: 15)
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
    
    
    func calc_subTotal() -> String {
        let sub_total = cart!.reduce(0) {$0 + ($1.movie!.price! * Double($1.quantity))}

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: sub_total))!
        
    }
    
    func getCartQtyData() {
        API(user: user).getCartQty(){ (result) in
            switch result {
            case .success(let qty):
                DispatchQueue.main.async {
                    self.qty = qty
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }
    
    func getCartData() {
        API(user: user).getCart { (result) in
            switch result {
            case .success(let cart):
                DispatchQueue.main.async {
                    UserCart.items = cart
                    self.cart = cart
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }
    
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
