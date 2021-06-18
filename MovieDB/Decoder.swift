//
//  Decoder.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 6/8/21.
//

import Foundation
import SwiftUI
import CoreData
import UIKit
import Combine

struct UserData: Codable {
    var id: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    var address: String = ""
    var unit: String = ""
    var email: String = ""
    var password: String = ""
    var city: String = ""
    var state: String = ""
    var postcode: String = ""
    var sales: [Sale] = [Sale]()
}

struct Sale: Codable {
    let id: Int
    let customerId: Int
    let saleDate: String
    let orders: [Order]
}

struct Order: Codable {
    let id: Int
    let orderId: Int
    let movieId: String
    let quantity: Int
    let list_price: Double
}

struct ResponseMeta: Codable {
    let size: Int
    let number: Int
    let totalElements: Int
    let last: Bool
    let totalPages: Int
    let sort: Sort
    let first: Bool
    let numberOfElements: Int
    let content: [MovieMeta]
}

struct MovieMeta: Codable {
    let sales: Int?
    let votes: Int?
    let rottenTomatoes: String?
    let name: String?
    let id: Int?
    let movieId: String?

}


struct Response: Codable {
    var size: Int
    var number: Int
    var totalElements: Int
    var last: Bool
    var totalPages: Int
    var sort: Sort
    var first: Bool
    var numberOfElements: Int
    var content: [Movie]
}


struct Sort:Codable {
    var unsorted: Bool?
    var sorted: Bool?
    var empty: Bool?
}



struct Movie:Codable, Equatable, Hashable, Identifiable{
    var uuid: UUID = UUID()
    
    var id: String = ""
    var title: String = ""
    var year: Int = 0
    var director: String = ""
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
    var genres: [Genre]?
    var cast: [Cast]?
    var ratings: Rating?
    var price: Double?
    var background: String?
    
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

    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Genre:Codable {
    var id: Int?
    var genreId: Int
    var movieId: String?
    var name: String
}

struct Rating:Codable {
    var movieId: String?
    var rating: Double
    var numVotes: Int
    var imdb: String?
    var metacritic: String?
    var rottenTomatoes: String?
}

struct Cast:Codable {
    var starId: String = ""
    var movieId: String?
    var category: String?
    var characters: String?
    var name: String = ""
    var photo: String?
    
    var birthYear: Int?
    var bio: String?
    var birthName: String?
    var birthDetails: String?
    var dob: String?
    var dod: String?
    var place_of_birth: String?
}

class CastDecode {
    @State var cast: Cast
    
    init(cast: Cast) {
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
        
        var str = ""
        if(category.count > 0) {
            str += category
        }
        
        if(character.count > 0) {
            str += " - \(character)"
        }
        
        return str
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
        return movie.director
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
            poster = ""
        }
        
        guard let url = URL(string: "\(poster)") else {
            preconditionFailure("Invalid static URL string: \(poster)")
        }
        
        return url
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
        
        
        let sub = String(self.movie.year) + " - " + rated + " - " + runtime
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
}
    
class RatingDecode {
    var ratings: Rating
    
    init(movie: Movie) {
        if let unwrapped = movie.ratings {
            self.ratings = unwrapped

        } else {
            self.ratings = Rating(movieId: "", rating: 0, numVotes: 0, imdb: "N/A", metacritic: "N/A", rottenTomatoes: "N/A")
        }
    }
    
    func getIMDB() -> String {
        if let unwrapped = ratings.imdb {
            return unwrapped
        }
        
        else {
            return "N/A"
        }
    }
    
    func getRottenTomatoes() -> (String,String) {
        var tomato = "rotten_na"
    
        if let unwrapped = ratings.rottenTomatoes {
            let float_score = Float(unwrapped.replacingOccurrences(of: "%", with: "")) ?? 0
            
            if float_score >= 60 {
                tomato = "rotten_fresh"
            }
            
            if float_score < 60 && float_score > 0 {
                tomato = "rotten_rotten"
            }
            
            return (tomato, unwrapped)
        }
        else {
            return (tomato, "N/A")
        }
    }
    
    func getMetaCritic() -> (Color, String) {
        var color_code = Color.gray
        
        if let unwrapped = ratings.metacritic {
            let split = unwrapped.components(separatedBy: "/")
            
            let number = Int(split[0]) ?? 0
            
            if(number >= 61){
                color_code = Color.green;
            }
            else if(number >= 40 && number <= 60){
                color_code = Color.yellow;
            }
            else if(number >= 20 && number <= 39){
                color_code = Color.red;
            }
            else {
                color_code = Color.gray;
            }
            
            return (color_code, split[0])
            
        }
        
        else {
            return (color_code, "0")
        }
    }
}


class UserDecode {
    var user: UserData
    
    init(user: UserData) {
        self.user = user
    }
    
    func firstName() -> String {
        let f_name = user.firstName
        if(f_name.isEmpty) {
            return "First Name"
        }
        
        return f_name
    }
    
    func lastName() -> String {
        let l_name = user.lastName
        if(l_name.isEmpty) {
            return "Last Name"
        }
        return l_name
    }
    
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
    
    func password() -> String {
        let email = user.password
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
}


class SaleDecode {
    var sale: Sale
    
    init(sale: Sale) {
        self.sale = sale
    }
    func getId() -> String {
        return "Order #" + String(sale.id)
    }
    
    func getDate() -> String {
        return sale.saleDate
    }
    
    func getTotal() -> String {
        let total = sale.orders.reduce(0) {$0 + ($1.list_price * Double($1.quantity))}
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: total))!
    }
    
    func getNumItems() -> Int {
        let total = sale.orders.reduce(0) {$0 + ($1.quantity)}
        
        
        return total
    }
}
