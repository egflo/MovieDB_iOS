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
    @State var movieData: Movie?
    @State var isActive = false;

    let width = (UIScreen.main.bounds.width - 33)
    let height = (UIScreen.main.bounds.height - 33)

    var body: some View {
        
        VStack {
            if let movie = movieData {
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
            
            else {
                ProgressView()
            }
        }
        .onAppear(perform: {getMovieData()})
    }
    
    
    func currencyFormater(num: Double) -> String {
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: num))!
    }
    
    func getMovieData() {
        API(user: user).getMovie(id: order.movieId) { (result) in
            switch result {
            case .success(let movie):
                DispatchQueue.main.async {
                    self.movieData = movie
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct OrderDetailsView: View {
    @EnvironmentObject var user: UserData
    
    @State var sale: Sale
    @State var saleDetails: SaleDetails?
    
    let width = (UIScreen.main.bounds.width - 33)
    let height = (UIScreen.main.bounds.height - 33)

    var body: some View {

        VStack{
            
            if let details = saleDetails {
                
                let decode = SaleDecode(sale: details.sale, card: details.card)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Shipping Address").font(.headline).bold()
                        
                        if(details.sale.shipping!.unit.count > 0) {
                            Text(details.sale.shipping!.unit).font(.subheadline)
                        }
                        
                        Text(details.sale.shipping!.address).font(.subheadline)
                        
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
                    
                }.frame(width:width, height: 100)
                
                                
                List(sale.orders!, id: \.id) { order in
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
        API(user: user).getSale(id: sale.id) { (result) in
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



struct OrderContentView: View {
    @EnvironmentObject var user: UserData

    @State var order: Order
    @State var movieData: Movie?
    
    let width = (UIScreen.main.bounds.width - 33)
    var body: some View {
        
        VStack {
            
            if let movie = movieData {
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
                        
                        Text(m.title()).font(.headline).foregroundColor(.blue)
                        Text(m.subString()).font(.subheadline).foregroundColor(.gray)

                    }
                    
                }
                .frame(height: 75)
                .onAppear(perform:{getMovieData()})

            }
            
            else {
                
                ProgressView()
         
            }
            
        }
        .onAppear(perform: {getMovieData()})
        
    }
    
    func getMovieData() {
        API(user: user).getMovie(id: order.movieId) { (result) in
            switch result {
            case .success(let movie):
                DispatchQueue.main.async {
                    self.movieData = movie
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
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
                    
                    
                    Text(decode.getDate())
                        .frame(width: width, alignment: .leading)
                    
                    Text("Total: \(decode.getTotal())").bold()

                    ForEach(decode.sale.orders ?? [Order](), id: \.id) { order in
                 
                        OrderContentView(order: order)
                 
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
    
    @StateObject var dataSource = ContentDataSourceOrders()
    let width = (UIScreen.main.bounds.width)

    var body: some View {
        
        VStack {
        
            Text("My Orders").font(.title).bold().frame(width:width-33, alignment: .leading)

            if(dataSource.items.count == 0) {
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
                        ForEach(dataSource.items, id: \.id) { sale in
                            let decode = SaleDecode(sale: sale)

                            if(dataSource.items.last == sale){
                                
                                VStack {

                                    OrderRowView(decode: decode)
                                }
                                .onAppear {
                                    print("Load More")
                                    dataSource.loadMoreContent(user: user)
                                }
                                .buttonStyle(PlainButtonStyle())
                                

                            }
                            else {
                                
                                VStack {

                                    OrderRowView(decode: decode)
                                }
                                //.onAppear {
                                //    print("Load More")
                               //     dataSource.loadMoreContent(user: user)
                               // }
                                .buttonStyle(PlainButtonStyle())
                                
                            }

                        }
                        
                    }.frame(width: width)
                    
                }.frame(width: UIScreen.main.bounds.width)
            }
            
        }
        //.offset(y: 15)
        
        .onAppear {
            print("Load More")
            dataSource.loadMoreContent(user: user)
        }
        
        .navigationBarHidden(true)
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
