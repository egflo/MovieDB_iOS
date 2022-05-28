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

struct OrderRowDetailView: View {
    @EnvironmentObject var user: UserData

    @State var order: Order
    @State var isActive = false;

    let width = (UIScreen.main.bounds.width - 33)
    let height = (UIScreen.main.bounds.height - 33)

    var body: some View {
        
        VStack {
             NavigationLink(destination: MovieView(movieId: order.movieId), isActive: $isActive) {
                    HStack {
                        let m = MovieDecode(movie: order.movie!)
                        
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
                            
                            Text(m.title()).font(.headline).foregroundColor(.blue)
                            Text(m.subString()).font(.subheadline).foregroundColor(.gray)

                        }
                        
                        Spacer()

                        VStack {
                            Text("\(currencyFormater(num: order.listPrice))")
                            Divider()
                            Text("Qty:  \(order.quantity)")
                        }.frame(width: 80)
                        
                    }
                    .frame(height: 90)
                    .onTapGesture{self.isActive = true}
               }

        }
    }
    
    
    func currencyFormater(num: Double) -> String {
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: num))!
    }
    
}

struct OrderDetailsView: View {
    @EnvironmentObject var user: UserData
    
    @State var sale: Sale
    @State var saleDetails: SaleDetails?
    
    let width = (UIScreen.main.bounds.width - 33)
    let height = (UIScreen.main.bounds.height - 33)

    var body: some View {

        GeometryReader {geometry in
         
            VStack {
                    
                if let details = saleDetails {
                    
                    let decode = SaleDecode(sale: details.sale, card: details.card)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Shipping Address").font(.headline).bold()
                                                    
                            if(details.sale.shipping!.unit.count > 0) {
                                Text(details.sale.shipping!.unit).font(.subheadline)
                            }
                            
                            Text(details.sale.shipping!.street).font(.subheadline)
                            
                            Text("\(details.sale.shipping!.city), \(details.sale.shipping!.state) \(details.sale.shipping!.postcode)").font(.subheadline)
                           
                            Text("United States").font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack (alignment: .trailing) {
                            
                            HStack {
                                Image(decode.getCardBrand())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 25)
                                
                                Text("**** \(details.card.last4)").font(.system(size: 15)).bold()
                            }
                            Text("Subtotal: \(decode.getSubTotal())").font(.system(size: 15)).bold()
                            
                            Text("Sales Tax: \(decode.getSalesTax())").font(.system(size: 15)).bold()
                            
                            Text("Shipping: $0.00").font(.system(size: 15)).bold()//.frame(width:width, alignment: .trailing)
                            
                            Text("Total: \(decode.getTotal())").font(.system(size: 22)).bold()
                        
                        }
                        
                    }.frame(width:geometry.size.width-33, height: 100)
                    
                                    
                    List(sale.orders, id: \.id) { order in
                        OrderRowDetailView(order:order)
                    }.listStyle(GroupedListStyle())
                    
                    .onAppear(perform: {
                        UITableView.appearance().isScrollEnabled = false
                    })
                    
                          
                }
                
                else {
                    
                    ProgressView()
                    
                }
                
                Spacer()
            
            }
                
        }
        .onAppear(perform: {
            self.getSaleData()
        })
        .navigationBarTitle(Text("Order #\(String(sale.id))"), displayMode: .large)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
        
    }
    
    
    func getSaleData() {
        let URL = "\(MyVariables.API_IP)/sale/\(sale.id)"
        NetworkManager.shared.getRequest(of: SaleDetails.self, url: URL) { (result) in
            switch result {
            case .success(let details):
                DispatchQueue.main.async {
                    self.saleDetails = details
                    
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}



struct OrderRowItem: View {
    @EnvironmentObject var user: UserData
    @State var order: Order
    
    let width = (UIScreen.main.bounds.width - 33)
    var body: some View {
        
        VStack {
            
            HStack {
                let m = MovieDecode(movie: order.movie!)
                
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
                    
                    Text(m.title()).font(.headline).foregroundColor(.blue)
                    Text(m.subString()).font(.subheadline).foregroundColor(.gray)

                }
                
            }
            .frame(height: 75)

        }
            
    }
            
}


struct OrderRowView: View {
    @State var decode: SaleDecode
    @State var isActive = false
    
    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {

        NavigationLink(destination: OrderDetailsView(sale: decode.sale), isActive: $isActive) {

            VStack {
                Divider().frame(width: width)
                    VStack(alignment: .leading) {
                        HStack {
                        
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 40)

                            
                            Text(decode.getId()).font(.system(size: 20)).bold()

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        
                    }
                    
                    Divider().frame(width: width, height: 5)
                    
                    
                    Text(decode.getDate()).bold().foregroundColor(Color.white)
                    
                    Text("Total: \(decode.getTotal())").bold().foregroundColor(Color.white)

                    ForEach(decode.sale.orders, id: \.id) { order in
                 
                        OrderRowItem(order: order)
                 
                    }
                        
                }
            }
        }
        .frame(width: width)
        .contentShape(Rectangle())
        .onTapGesture {
            self.isActive = true
        }
    }
}




struct OrderView: View {
    @EnvironmentObject var user: UserData
    @StateObject var dataSource = ContentDataSourceTest<Sale>()

    var body: some View {
        
        GeometryReader {geometry in
            VStack {
                if(dataSource.items.count == 0 && !dataSource.isLoadingPage) {
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
                
                else if(dataSource.isLoadingPage) {
                    ProgressView()
                }
                
                else {
                    ScrollView {
                        LazyVStack{
                            ForEach(dataSource.items, id: \.uuid) { sale in
                                let decode = SaleDecode(sale: sale)
                                OrderRowView(decode: decode)
                                    .onAppear(perform: {
                                        if !self.dataSource.endOfList {
                                            if self.dataSource.shouldLoadMore(item: sale) {
                                                self.dataSource.fetch(path: "sale/")
                                            }
                                        }
                                    })

                            }
                            
                        }
                        
                    }.frame(width:geometry.size.width)
                    
                }
                
            }
        
        }
        .onAppear(perform: {
            dataSource.fetch(path: "sale/")
        })
        
        .navigationBarHidden(false)
        .navigationBarTitle(Text("Orders"), displayMode: .large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
    }
    
    
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView()
    }
}
