//
//  Decoder.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 6/8/21.
//

import SwiftUI
import CoreData
import UIKit
import Combine
import Foundation



/*
    API GENERIC RESPONSE
 */
struct ResponseStatus<T: Codable>: Codable {
    var success: Bool
    var message: String
    var status: Int
    var data: T?
}

/*
    STRIPE RESPONSE
 */

struct PaymentData: Codable {
    var id: String = ""
    var last4: String = ""
    var receipt_url: String = ""
    var exp_month: String = ""
    var currency: String = ""
    var exp_year: String = ""
    var status: String = ""
    var network: String = ""
    var amount: Int = 0
}


struct PaymentIntent: Codable {
    let amount: Double
    let created: Int
    let currency: String
    let id: String
    let secret: String
}


struct UserToken: Codable {
    let id: Int
    let username: String
    let accessToken: String
    let refreshToken: String
    let type: String
    //let roles: [Set<Authority>]
}


/*
    CART DATA STRUCTURE
 */

struct Cart: Codable {
    let id: Int
    let userId: String
    let movieId: String
    let createdDate: Int
    let movie: Movie?
    var quantity: Int
}

struct CartResponse: Codable {
    let status: Int
    let message: String
    let success: Bool
    let data: Cart?
}

/*
    USER DATA STRUCTURE
 */

struct Email: Codable {
    var id: Int = 0
    var email: String = ""
    var newEmail: String = ""
    var password: String = ""
}

struct Password: Codable {
    var id: Int = 0
    var password: String = ""
    var newPassword: String = ""
}

struct Address: Codable, Hashable, Equatable{
    var id: Int = 0
    var firstname: String = ""
    var lastname: String = ""
    var street: String = ""
    var unit: String = ""
    var city: String = ""
    var state: String = ""
    var postcode: String = ""
    
    /**
     func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }
     
     static func ==(lhs: Address, rhs: Address) -> Bool {
         return lhs.id == rhs.id
     }
     */

}


struct User: Codable {
    let id: Int
    let firstname: String
    let lastname: String
    let email: String
    let primaryAddress: Int
    let created: Int
    var sales: [Sale] = [Sale]()
    var addresses: [Address] = [Address]()
    var reviews: [Review] = [Review]()
    let authorities: [Authority]
}

struct Authority: Codable {
    let authority: String
    
}

/*
    Sale DATA STRUCTURE
 */

struct SaleDetails: Codable {
    let sale: Sale
    let card: Card
}

struct Card: Codable {
    let country: String
    let last4: String
    let funding: String
    let exp_month: Int
    let exp_year: Int
    let brand: String
    let network: String
}

struct Sale: Codable, Equatable {
    var uuid: UUID = UUID()

    let id: Int
    let customerId: Int
    let saleDate: Int
    let salesTax: Double
    let subTotal: Double
    let total: Double
    let stripeId: String
    let status: String
    let device: String
    var orders: [Order] = [Order]()
    let shipping: Shipping?
    
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case customerId
        case saleDate
        case salesTax
        case subTotal
        case total
        case stripeId
        case status
        case device
        case orders
        case shipping
    }
    
    static func ==(lhs: Sale, rhs: Sale) -> Bool {
        return lhs.id == rhs.id
    }

}

struct Order: Codable {
    let id: Int
    let orderId: Int
    let movieId: String
    let quantity: Int
    let listPrice: Double
    let movie: Movie?
}

struct Shipping: Codable {
    var id: Int
    var firstname: String
    var lastname: String
    var street: String
    var unit: String = ""
    var city: String
    var state: String
    var postcode: String
}


/*
    PAGABLE STRUCTURE
 */

struct Response<T: Codable>: Codable {
    var content: [T]
    var pageable: Pagable
    var totalPages: Int
    var totalElements: Int
    var last: Bool
    var size: Int
    var number: Int
    var sort: Sort
    var numberOfElements: Int
    var first: Bool
    var empty: Bool
}


struct Pagable:Codable {
    var sort: Sort
    var offset: Int
    var pageNumber: Int
    var pageSize: Int
    var paged: Bool
    var unpaged: Bool
}

struct Sort:Codable {
    var unsorted: Bool
    var sorted: Bool
    var empty: Bool
}


/*
    Movie STRUCTURE
 */

struct MovieSimplified: Codable {
    var id: String
    var title: String
    var year: Int
    var director: String?
    var poster: String?
    var plot: String?
    var rated: String?
    var runtime: String?
    var background: String?
    var price: Double?
    var updated: Int?
    var inventory: Inventory?
}


struct Movie:Codable, Equatable, Hashable, Identifiable, Comparable{
    var uuid: UUID = UUID()
    
    var id: String
    var title: String
    var year: Int
    var director: String?
    var poster: String?
    var plot: String?
    var rated: String?
    var runtime: String?
    var language: String?
    var writer: String?
    var awards: String?
    var boxOffice: String?
    var production: String?
    var country: String?
    var background: String?
    var genres: [Genre]?
    var cast: [Cast]?
    var ratings: Rating?
    var price: Double?
    let inventory: Inventory
    let updated: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case title
        case year
        case director
        case poster
        case plot
        case rated
        case runtime
        case language
        case writer
        case awards
        case boxOffice
        case production
        case country
        case genres
        case cast
        case ratings
        case price
        case background
        case inventory
        case updated

    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id < rhs.id
    }
    
}


struct Cast:Codable {
    //var id: Int
    var uuid: UUID = UUID()
    
    var starId: String
    var movieId: String?
    var category: String?
    var characters: String?
    var name: String?
    var photo: String?
    var movie: Movie?
    
    enum CodingKeys: String, CodingKey {
        
        case starId
        case movieId
        case category
        case characters
        case name
        case photo
        case movie

    }
}


struct Rating:Codable {
    var rating: Double?
    var numVotes: Int?
    var imdb: String?
    var metacritic: String?
    var rottenTomatoes: String?
    var rottenTomatoesAudience: String?
    var rottenTomatoesStatus: String?
    var rottenTomatoesAudienceStatus: String?
}

struct Inventory: Codable {
    let quantity: Int
    let status: String
}

struct CustomerSimplified: Codable {
    let firstname: String
    let lastname: String
    let id: Int
    let email: String
}


struct Review: Codable, Equatable {
    let id: Int
    let movieId: String
    let customerId: Int
    let text: String
    let rating: Int
    let sentiment: String
    let title: String
    let created: Int
    let customer: CustomerSimplified
    let movie: Movie
    
    static func ==(lhs: Review, rhs: Review) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ResponseReviews: Codable {
    var content: [Review] = [Review]()
    var pageable: Pagable
    var totalPages: Int
    var totalElements: Int
    var last: Bool
    var size: Int
    var number: Int
    var sort: Sort
    var numberOfElements: Int
    var first: Bool
    var empty: Bool
}


/*
    CAST INFORMATION STRUCTURE
 */


struct Star: Codable {
    var starId: String = ""
    var name: String = ""
    var photo: String?
    var birthYear: Int?
    var bio: String?
    var birthName: String?
    var birthDetails: String?
    var dob: String?
    var dod: String?
    var place_of_birth: String?
    var movies: [Cast] = [Cast]()
}


struct CastResponse: Codable {
    var content: [Star] = [Star]()
    var pageable: Pagable
    var totalPages: Int
    var totalElements: Int
    var last: Bool
    var size: Int
    var number: Int
    var sort: Sort
    var numberOfElements: Int
    var first: Bool
    var empty: Bool
}


/*
    META INFORMATION STRUCTURE
 */


struct ResponseMeta: Codable {
    var content: [MovieMeta] = [MovieMeta]()
    var pageable: Pagable
    var totalPages: Int
    var totalElements: Int
    var last: Bool
    var size: Int
    var number: Int
    var sort: Sort
    var numberOfElements: Int
    var first: Bool
    var empty: Bool
}


struct Genre: Codable {
    let id: Int
    let name: String
}


struct MovieMeta: Codable, Equatable, Hashable, Identifiable {
    var uuid: UUID = UUID()

    let sales: Int?
    let votes: Int?
    let rottenTomatoes: String?
    let name: String?
    let id: Int?
    let movieId: String?
    let movie: Movie?
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case movieId
        case name
        case rottenTomatoes
        case votes
        case sales
        case movie
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: MovieMeta, rhs: MovieMeta) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}


/*
    CHECKOUT STRUCTURE
 */


struct Checkout: Codable {
    var defaultId: Int = 0
    var total: Double = 0.0
    var addresses: [Address] = [Address]()
    var subTotal: Double = 0.0
    var salesTax: Double = 0.0
    var cart: [Cart] = [Cart]()
}

struct ProcessOrder: Codable {
    let total: Double
    let subtotal: Double
    let salesTax: Double
    let cart: [Cart]
    let address: Address
    let customerId: Int
    let stripeId: String
}


/*
    BOOKMARK STRUCTURE
 */

struct BookmarkResponse: Codable {
    var bookmark: Bookmark?
    let success: Bool
    let message: String
}

struct Bookmark: Codable {
    var id: Int
    var customerId: Int
    var movieId: String
    var created: Int?
}


/*
    DECODER CLASSES
 */

class CastDecode {
    @State var cast: Cast
    
    init(cast: Cast) {
        self.cast = cast
    }
    
    func name() -> String {
        return cast.name!
    }
    

    func photo() -> String {
        var photo: String
                
        if let unwrapped = self.cast.photo {
            photo = unwrapped
        } else {
            photo = ""
        }
        
        return photo
    }
    
    private func subCastCategory() -> String {
        if let unwrapped = cast.category {
            return unwrapped.capitalized
        } else {
            return ""
        }
    }
    
    private func subCastCharacter() -> String {
        if let unwrapped = cast.characters {
            let json = Data(unwrapped.utf8)
            if let decodedResponse = try? JSONDecoder().decode([String].self, from: json) {
                
                // everything is good, so we can exit
                //There can be more charcters fix
                return decodedResponse[0]
            }
            
        } else {
            return ""
        }
        
        return ""
    }
    
    func subStringCast() -> String {
        let category = subCastCategory()
        let character = subCastCharacter()
        
        if(character.count > 0) {
            return character
        }
        
        else {
            return category
        }
        /**
         var str = ""
         if(category.count > 0) {
             str += category
         }
         
         if(character.count > 0) {
             str += " - \(character)"
         }
         
         return str
         
         */

    }
}


class StarDecode {
    @State var cast: Star
    
    init(cast: Star) {
        self.cast = cast
    }
    
    func name() -> String {
        return cast.name
    }
    
    func year() -> String {
        var year: String
                
        if let unwrapped = self.cast.birthYear {
            year = String(unwrapped)
            
        } else {
            year = ""
        }
        
        return year
    }
    
    func photo() -> String {
        var photo: String
                
        if let unwrapped = self.cast.photo {
            photo = unwrapped
        } else {
            photo = ""
        }
        
        return photo
    }
    
    
    func subString() -> String {
        var dob: Int
        var dod: String
        
        if let unwrapped = cast.birthYear {
            dob =  unwrapped
        }
        else {
            return ""
        }
        
        if let unwrapped = cast.dod {
            dod =  String(unwrapped.prefix(4))
        }
        else {
            return "(\(dob))"
        }
        
        return  "(\(dob) - \(dod))"
    }

    
    func bio() -> String {
        var bio:String
        
        if let unwrapped = self.cast.bio {
            bio = unwrapped
            if (bio.count < 5 ){
                bio  = "No Bio Avaliable For \(cast.name)."
            }
            
        } else {
            bio  = "No Bio Avaliable For \(cast.name)."
        }
        
        return bio
    }
    
    func birthDetails() -> String {
        var details:String
        
        if let unwrapped = self.cast.birthDetails {
            details =  unwrapped
            if (details.count < 5 ){
                details  = "No Details Avaliable For \(cast.name)"
            }
            
            else {
                details = "Born on " + details
            }
            
        } else {
            details  = "No Details Avaliable For \(cast.name)"
        }
        
        return details
    }
    
}
    
class MovieDecode {
    @State var movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    func title() -> String {
        return movie.title
    }
    
    func director() -> String {
        return movie.director ?? ""
    }
    
    func year() -> Int {
        return movie.year
    }

    func background() -> String {
        var background: String
                
        if let unwrapped = self.movie.background {
            background = unwrapped
        } else {
            background = ""
        }
        
        return background
    }
    
    func poster() -> String {
        var poster:String
        
        if let unwrapped = self.movie.poster {
            poster = unwrapped
        } else {
            poster = ""
        }
        
        return poster
    }

    func country() -> String {
        var country:String
        
        if let unwrapped = self.movie.country {
            country = unwrapped
        } else {
            country = "No Country Information Available"
        }
        
        return country
    }
    
    func language() -> String {
        var language:String
        
        if let unwrapped = self.movie.language {
            language = unwrapped
        } else {
            language = "No Language Information Available"
        }
        
        return language
    }
    
    func writer() -> String {
        var writer:String
        
        if let unwrapped = self.movie.writer {
            writer = unwrapped
        } else {
            writer = "No Writer(s) Information Available"
        }
        
        return writer
    }
    
    func award() -> String {
        var awards:String
        
        if let unwrapped = self.movie.awards {
            awards = unwrapped
        } else {
            awards = "No Award Information Available"
        }
        
        return awards
    }
    
    func boxOffice() -> String {
        var boxOffice:String
        
        if let unwrapped = self.movie.boxOffice {
            boxOffice = unwrapped
        } else {
            boxOffice = "No Box Office Information Available"
        }
        
        return boxOffice
    }
    
    func production() -> String {
        var production:String
        
        if let unwrapped = self.movie.production {
            production = unwrapped
        } else {
            production = "No Production Information Available"
        }
        
        return production
    }
    
    func plot() -> String {
        var plot:String
        
        if let unwrapped = self.movie.plot {
            plot = unwrapped
            if (plot.count < 5 ){
                plot  = "No Summary Information Available For \(self.movie.title)."
            }
            
        } else {
            plot  = "No Summary Information For \(self.movie.title)."
        }
        
        return plot
    }
    
    
    func posterURL() -> URL {
        var poster:String
        
        if let unwrapped = self.movie.poster {
            poster = unwrapped
        } else {
            poster = "no_image"
        }
        
        //guard let url = URL(string: "\(poster)") else {
        //    preconditionFailure("Invalid static URL string: \(poster)")
        //}
        
        return URL(string: "\(poster)")!
    }
    
    
    func subString() -> String {
        
        var rated: String
        var runtime:String
        
        if let unwrapped = self.movie.rated {
            rated = unwrapped
            let lowercased = rated.lowercased()
            if(lowercased.elementsEqual("not rated") || lowercased.elementsEqual("unrated")){
                rated = "NR"
            }
        } else {
            rated = "Not Rated"
        }
        
        if let unwrapped = self.movie.runtime {
            let str = unwrapped.replacingOccurrences(of: " min", with: "", options: .literal, range: nil)
            let minutes = Int(str) ?? 0

            let hours = (minutes/60)
            let remaining_minutes = (minutes % 60)
            
            runtime = "\(hours) hr \(remaining_minutes) min"
            
            if(minutes == 0) {
                runtime = "Runtime Unavailable"
            }
            

        } else {
            runtime = "Runtime Unavailable"
        }
        
        
        let sub = String(self.movie.year) + " \u{2022} " + rated + " \u{2022} " + runtime
        return sub
    }
    
    func subStringMin() -> String {
        
        var rated: String
        
        if let unwrapped = self.movie.rated {
            rated = unwrapped
            let lowercased = rated.lowercased()
            if(lowercased.elementsEqual("not rated") || lowercased.elementsEqual("unrated")){
                rated = "NR"
            }
        } else {
            rated = "Not Rated"
        }
        
        
        let sub = String(self.movie.year) + " - " + rated
        return sub
    }
    
    func subheadline() -> AnyView {
        
        return (
            AnyView(
                HStack {
                    Text(String(self.movie.year))
                    .padding(.trailing, 4)
                    .padding(.leading, 4)
                        .background(Capsule().fill(Color.gray))
                    
                    if let rated = self.movie.rated {
                        //Stack{
                            Text("\(rated)")
                            .frame(minWidth: 20)
                            .padding(.trailing, 4)
                            .padding(.leading, 4)
                                .background(Capsule().fill(Color.gray))
                            
                        //}.fixedSize()
                    }
                    
                    if let minutes = self.movie.runtime {
                        
                        let minutes = Int(minutes) ?? 0

                        let hours = (minutes/60)
                        let remaining_minutes = (minutes % 60)
                        
                        let runtime = "\(hours) hr \(remaining_minutes) min"
                        
                        if(hours == 0 && remaining_minutes == 0) {
        
                            
                        }
                       
                        else {
                            Text("\(runtime)")
                            .padding(.trailing, 4)
                            .padding(.leading, 4)
                                .background(Capsule().fill(Color.gray))
                        }
                        
                        
                    }

                }

            )

        )
    }
    
    func price(f: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        let price = f
        let str = formatter.string(from: NSNumber(value: price))
        return str!
 
    }
    
    
    func price() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        var price: Double
        
        if let unwrapped = self.movie.price {
            price = unwrapped
            let str = formatter.string(from: NSNumber(value: price))
            return str!
        } else {
            return "N/A"
        }
    }
    
    
    func inventoryStatus() -> AnyView {
        let inventory = self.movie.inventory
        let quantity = inventory.quantity
        let status = inventory.status.uppercased()
        var color = Color(UIColor(red: 0.07, green: 0.55, blue: 0.13, alpha: 1.00))
        
        if(status == "LIMITED") {
            color = Color(UIColor(red: 0.92, green: 0.59, blue: 0.01, alpha: 1.00))
        }
        
        if(status == "OUT OF STOCK") {
            color = Color.red
        }
        
        return AnyView(
            Text(status)
                .padding(.leading,5)
                .padding(.trailing,5)
                .foregroundColor(.white)
                .background(Capsule().fill(color))
            //ZStack{
            //    RoundedRectangle(cornerRadius: 8)/
            //        .foregroundColor(color)
            //    HStack{
            //        Text(status).font(.headline).foregroundColor(.white)
            //    }
           // }.fixedSize()
            //    .border(Color.red)
            //
            //Text(status.uppercased())
            //    .background(color)
             //   .clipShape(Capsule())
        )
    }
}
    
class RatingDecode {
    var ratings: Rating
    
    init(movie: Movie) {
        if let unwrapped = movie.ratings {
            self.ratings = unwrapped

        } else {
            self.ratings = Rating(rating: 0, numVotes: 0, imdb: "N/A", metacritic: "N/A", rottenTomatoes: "N/A")
        }
    }
    
    func getIMDB() -> AnyView {
        
        //var text = Group{Text("N/A").font(.system(size: 12)).bold()}
        
        if let unwrapped = ratings.imdb {
            //let split = unwrapped.components(separatedBy: "/")
            //let text = Group{Text(split[0]).font(.system(size: 14)).bold() + Text("/\(split[1])").font(.system(size: 10)).bold().foregroundColor(.gray)}
           
            let text = Group{Text(unwrapped).font(.system(size: 14)).bold() + Text("/10").font(.system(size: 10)).bold().foregroundColor(.gray)}
                
            
            return AnyView(
                HStack(spacing: 0) {
                    Image("imdb")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 27)

                    text.padding(.leading,5).padding(.trailing,5).shadow(radius: 5)
                        //.background(RoundedRectangle(cornerRadius: 2).fill(Color.white))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(Color(UIColor(red: 0.93, green: 0.71, blue: 0.04, alpha: 1.00)), lineWidth: 2)
                        //.background(RoundedRectangle(cornerRadius: 2).fill(Color.white))
                    )
            )
        }
        
        else {
            return AnyView(HStack{})
        }
        
    }
    
    func getRottenTomatoes() -> AnyView {
        var tomato = "Rotten_NA"
        var audience = "Rotten_NA_aud"

        var score = "N/A"
        var aud_score = "N/A"

    
        if let unwrapped = ratings.rottenTomatoes {
            //let float_score = Float(unwrapped.replacingOccurrences(of: "%", with: "")) ?? 0
            let float_score = Float(unwrapped) ?? 0
            
            if float_score >= 60 {
                tomato = "Fresh"
            }
            
            if float_score < 60 && float_score > 0 {
                tomato = "Rotten"
            }
            
            score = unwrapped
        }
        
        if let unwrapped = ratings.rottenTomatoesAudience {
            //let float_score = Float(unwrapped.replacingOccurrences(of: "%", with: "")) ?? 0
            let float_score = Float(unwrapped) ?? 0
            
            if float_score >= 60 {
                audience = "Upright"
            }
            
            if float_score < 60 && float_score > 0 {
                audience = "Spilled"
            }
            
            aud_score = unwrapped
        }
        
        if let unwrapped = ratings.rottenTomatoesStatus {
            tomato = unwrapped
        }
        
        if let unwrapped = ratings.rottenTomatoesAudienceStatus {
            audience = unwrapped
        }

        
        return AnyView(
            HStack (spacing: 0) {
                if(score != "N/A") {
                    Image(tomato)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                    Text("\(score)%").font(.system(size: 18)).bold().shadow(radius: 5).padding(.leading,2)
                }
                
                if(aud_score != "N/A") {
                    Image(audience)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .padding(.leading, 5)
                    Text("\(aud_score)%").font(.system(size: 18)).bold().shadow(radius: 5).padding(.leading,2)
                    
                }
            }

        )
    }
    
    func getMetaCrticRow() -> AnyView {
        if let unwrapped = ratings.metacritic {
            
            if(unwrapped.isEmpty) {
                
                return AnyView(VStack{})
            }
            
            var score = unwrapped.components(separatedBy: ".")[0]

            if(unwrapped.contains("/")) {
                score = unwrapped.components(separatedBy: "/")[0]
            }

            return AnyView (
        
                HStack(spacing: 0) {
                    Image("metacritic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)

                    Text(score).font(.system(size: 18)).bold().shadow(radius: 5)
                        .padding(.leading,4)
                }
            )
        }
        
        else {
            return AnyView(VStack{})
        }
        
    }
    
    func getMetaCritic() -> AnyView {
        var color = Color.gray
        var score = "N/A"
        
        if let unwrapped = ratings.metacritic {
            
            var number = 0
            if(unwrapped.count != 0) {
                if(unwrapped.contains("/")){
                    let split = unwrapped.components(separatedBy: "/")
                    number = Int(split[0]) ?? 0
                }
                
                else {
                    number = Int(Float(unwrapped) ?? 0)
                }
                
            }
            

            if(number >= 61){
                color = Color.green;
            }
            else if(number >= 40 && number <= 60){
                color = Color.yellow;
            }
            else if(number >= 20 && number <= 39){
                color = Color.red;
            }
            else {
                color = Color.gray;
            }
            
            score = String(number)
            
        }
        
        return AnyView (
        
            VStack(alignment: .leading) {
                Text(score).font(.system(size: 22)).bold()
                    .foregroundColor(Color.white)
                    .background(Rectangle()
                    .fill(color)
                    .frame(width: 40, height: 40)
                    .cornerRadius(8))
                
            }.frame(width: 40, height: 40)
        )
    }
    
}


class UserDecode {
    var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func firstName() -> String {
        let f_name = user.firstname
        if(f_name.isEmpty) {
            return "First Name"
        }
        
        return f_name
    }
    
    func lastName() -> String {
        let l_name = user.lastname
        if(l_name.isEmpty) {
            return "Last Name"
        }
        return l_name
    }
    
    /**
     func address() -> String {
         let address = user.address
         if(address.isEmpty) {
             return "Address"
         }
         return address
     }
     
     func unit() -> String {
         let unit = user.unit
         if(unit.isEmpty) {
             return "Unit/P.O Box"
         }
         return unit
     }
     
     func email() -> String {
         let email = user.email
         if(email.isEmpty) {
             return "Email"
         }
         return email
     }
     
     func city() -> String {
         let city = user.city
         if(city.isEmpty) {
             return "City"
         }
         return city
     }
     
     func state() -> String {
         let state = user.state
         if(state.isEmpty) {
             return "State"
         }
         return state
     }
     
     func postcode() -> String {
         let postcode = user.postcode
         if(postcode.isEmpty) {
             return "Postcode/Zipcode"
         }
         return postcode
     }
     
     func validEmail() -> Bool {
         let regex =  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
         let namePredicate = NSPredicate(format: "SELF MATCHES%@", regex)
         return namePredicate.evaluate(with: self.user.email)
     }
     */

}


class SaleDecode {
    var sale: Sale
    var card: Card?
    
    var formatter: NumberFormatter
    
    init(sale: Sale, card: Card? = nil) {
        self.sale = sale
        
        if let unwrapped = card {
            self.card = unwrapped
        }
        
        self.formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
    }
    
    func getId() -> String {
        return "Order #" + String(sale.id)
    }
    
    func getDate() -> String {
        
        let epochTime = TimeInterval(sale.saleDate) / 1000
        let date = Date(timeIntervalSince1970: epochTime)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"

        return df.string(from: date)
    }
    
    func getSubTotal() -> String {
        
        return formatter.string(from: NSNumber(value: sale.subTotal))!
    }
    
    func getSalesTax() -> String {
        
        return formatter.string(from: NSNumber(value: sale.salesTax))!
    }
    
    func getTotal() -> String {
        
        return formatter.string(from: NSNumber(value: sale.total))!
    }
    
    func getNumItems() -> Int {
        let total = sale.orders.reduce(0) {$0 + ($1.quantity)}
        return total
    }
    
    func getCardBrand() -> String {
        
        var brand = "visa"

        if let unwrapped = card {
            let card = unwrapped
            
            if(card.brand == "amex")
            {
                brand = "amex"
            }
            
            else if(card.brand == "discover") {
                brand = "discover"
            }
            
            else if(card.brand == "mastercard") {
                brand = "mastercard"
            }
            
        }

        return brand
    }
}
