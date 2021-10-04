//
//  JSON_Parser.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/17/21.
//

import SwiftUI
import CoreData
import UIKit
import Combine
import Stripe

struct MyVariables {
    //static var API_IP = "http://10.81.1.123:8080/moviedb_api"
    static var API_IP = "http://10.81.1.109:8080"
    static var STRIPE_PUBLIC_KEY = ""
}

struct UserCart {
    static var items = [Cart]()
    
    private init() {}
}

class UserData: ObservableObject {
    @Published var data = User()
    @Published var isLoggedin = false
    @Published var id = 0
    @Published var username = ""
    @Published var token = ""

}

enum APIError: Error {
    case invalidJSON
    case invalidResponeCode
    case invalidQty
    case invalidURL
    case invalidCredentials
}


extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return NSLocalizedString("Unable to Encode Data Model", comment: "Invalid JSON")
        case .invalidResponeCode:
            return NSLocalizedString("Invalide Respone Code", comment: "Non 200 Status Code")
        case .invalidQty:
            return NSLocalizedString("Invalid Quantity Selected", comment: "Invalid Qty")
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Bad URL")
        case .invalidCredentials:
            return NSLocalizedString("Incorrect Email/Password", comment: "Bad Username/Password")

        }
    }
}



class API: ObservableObject {
    var userId: Int
    var token: String
    
    init(user: UserData) {
        self.userId = user.id
        self.token = user.token
    }
    
    func authUser(username: String, password: String, completion: @escaping (Result<UserToken,Error>) -> Void) {
        let url = "\(MyVariables.API_IP)/user/auth"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        struct UploadData: Codable {
            let username: String
            let password: String
        }
        
        
        let uploadDataModel = UploadData(username: username, password: password)
        
        guard let data = try? JSONEncoder().encode(uploadDataModel) else {
            return
         }

        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    
                    if(responseCode == 401) {
                        completion(.failure(APIError.invalidCredentials))
                        return
                    }
                    
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                if let decodedResponse = try? JSONDecoder().decode(UserToken.self, from: responseData) {
                    DispatchQueue.main.async {
                        completion(.success(decodedResponse))
                    }
                }
            }
        }.resume()
        
    }
    
    func getCartQty(completion: @escaping (Result<Int,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cart/qty/\(userId)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")


        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(Int.self, from: data!)
                completion(.success(response))
                
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    }

    
    
    func updateBookmark(id: String, completion: @escaping (Result<Bookmark,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/bookmark/update"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        struct UploadData: Codable {
            let customerId: Int
            let movieId: String
        }
                
        let uploadDataModel = UploadData(customerId: userId, movieId: id)

        
        guard let data = try? JSONEncoder().encode(uploadDataModel) else {
            completion(.failure(APIError.invalidJSON))
            return
         }
        
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                
                guard responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let response = try? JSONDecoder().decode(Bookmark.self, from: responseData) {
                    print("Response JSON data = \(response)")
                    completion(.success(response))
                }
            }
        }.resume()
        
    }

    
    func getBookmark(id: String, completion: @escaping (Result<Bookmark,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/bookmark/customer/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = data {
                guard responseCode == 200 else {
                    
                    if responseCode == 404 {
                        //Return Empty Bookmark (i.e not found)
                        completion(.success(Bookmark(id: 0, customerId: 0, movieId: id, created: 0)))
                        return
                    }
                    
                    else {
                        completion(.failure(APIError.invalidResponeCode))
                        return
                    }

                }
                
                do {
                    let bookmark = try JSONDecoder().decode(Bookmark.self, from: responseData)
                    print("Response JSON data = \(bookmark)")
                    completion(.success(bookmark))
                    
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
            }
            
        }.resume()
    }
    
    
    func getSale(id: Int, completion: @escaping (Result<SaleDetails,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/sale/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                let sale = try JSONDecoder().decode(SaleDetails.self, from: data!)
                print("Response JSON data = \(sale)")
                completion(.success(sale))
                
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    }
    
    
    func uploadOrder(checkout: Checkout, paymentIntent: STPPaymentIntentParams, completion: @escaping (Result<Sale,Error>) -> Void) {
        
        // Prepare URL
        let url = "\(MyVariables.API_IP)/sale/add"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        struct Shipping: Codable {
            let customerId: Int
            let firstName: String
            let lastName: String
            let address: String
            let unit: String
            let city: String
            let state: String
            let postcode: String

        }
    
        struct UploadData: Codable {
            let total: Double
            let subTotal: Double
            let salesTax: Double
            let customerId: Int
            let stripeId: String
            let shipping: Shipping
        }
        
        let uploadShippingModel = Shipping(customerId: userId, firstName: checkout.address.firstName, lastName: checkout.address.lastName, address: checkout.address.address, unit: checkout.address.unit, city: checkout.address.city, state: checkout.address.state, postcode: checkout.address.postcode)
        
        let uploadDataModel = UploadData(total: checkout.total, subTotal: checkout.subTotal, salesTax: checkout.salesTax, customerId: userId, stripeId: paymentIntent.stripeId!, shipping: uploadShippingModel)

        
        guard let data = try? JSONEncoder().encode(uploadDataModel) else {
            completion(.failure(APIError.invalidJSON))
            return
         }
        
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                
                guard responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let response = try? JSONDecoder().decode(Sale.self, from: responseData) {
                    print("Response JSON data = \(response)")
                    completion(.success(response))
                }
            }
        }.resume()
        
    }
    
    
    func preparePaymentIntent(amount: Double, currency: String, description: String, completion: @escaping (Result<STPPaymentIntentParams,Error>) -> Void) {
        
        // Prepare URL
        let url = "\(MyVariables.API_IP)/checkout/charge"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        struct UploadData: Codable {
            let amount: Double
            let currency: String
            let description: String
        }
        
        let uploadDataModel = UploadData(amount: amount, currency: currency, description: description)
        
        
        guard let data = try? JSONEncoder().encode(uploadDataModel) else {
            completion(.failure(APIError.invalidJSON))
            return
         }
        
        // Perform HTTP Request
        let task = URLSession.shared.uploadTask(with: request, from: data) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let data = data {
                guard responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                do {
                    
                    /*
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let client_secret = json["client_secret"] as? String {
                            print(client_secret)
                            completion(.success(STPPaymentIntentParams(clientSecret: client_secret)))
                        }
                        else {
                            completion(.failure(APIError.invalidJSON))
                        }
            
                    }
                    */
                    
                    let paymentIntent = try JSONDecoder().decode(PaymentIntent.self, from: data)
                    print("Response JSON data = \(paymentIntent)")
                    completion(.success(STPPaymentIntentParams(clientSecret: paymentIntent.secret)))

                } catch let error as NSError {
                    completion(.failure(error))
                }

            }
        }
        task.resume()
    }
    
    func getCheckout(completion: @escaping (Result<Checkout,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/checkout/\(self.userId)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            do {
                let checkout = try JSONDecoder().decode(Checkout.self, from: data!)
                print("Response JSON data = \(checkout)")
                completion(.success(checkout))
                
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    }
    
    func addCart(movieId: String, qty: Int, completion: @escaping (Result<CartDelete,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cart/add"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        struct UploadData: Codable {
            let userId: String
            let movieId: String
            let qty: Int
        }
        
        let uploadDataModel = UploadData(userId: String(userId), movieId: movieId, qty: qty)
        
        
        guard let data = try? JSONEncoder().encode(uploadDataModel) else {
            completion(.failure(APIError.invalidJSON))
            return
         }

        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making POST request: \(error.localizedDescription)")
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let cart = try? JSONDecoder().decode(CartDelete.self, from: responseData) {
                    print("Response JSON data = \(cart)")
                    completion(.success(cart))
                }
            }
        }.resume()
    }
    
    func deleteCart(cartId: Int, completion: @escaping (Result<CartDelete,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cart/delete"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        struct UploadData: Codable {
            let id: Int
        }
        
        let uploadDataModel = UploadData(id: cartId)
        
        
        guard let data = try? JSONEncoder().encode(uploadDataModel) else {
            completion(.failure(APIError.invalidJSON))
            return
         }

        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making POST request: \(error.localizedDescription)")
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let cart = try? JSONDecoder().decode(CartDelete.self, from: responseData) {
                    print("Response JSON data = \(cart)")
                    completion(.success(cart))
                }
            }
        }.resume()
    }

    func updateCart(cartId: Int, qty: Int, completion: @escaping (Result<Cart,Error>) -> Void) {
        
        if(qty > 4 || qty < 1) {
            completion(.failure(APIError.invalidQty))
            return
        }
        
        let url = "\(MyVariables.API_IP)/cart/update"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        struct UploadData: Codable {
            let id: Int
            let qty: Int
        }
        
        
        let uploadDataModel = UploadData(id: cartId, qty: qty)
        
        
        guard let data = try? JSONEncoder().encode(uploadDataModel) else {
            completion(.failure(APIError.invalidJSON))
            return
         }

        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making POST request: \(error.localizedDescription)")
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let cart = try? JSONDecoder().decode(Cart.self, from: responseData) {
                    print("Response JSON data = \(cart)")
                    completion(.success(cart))
                }
            }
        }.resume()
    }
    
    func getUser(completion: @escaping (Result<User,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/customer/\(self.userId)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = data {
                guard responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(User.self, from: responseData)
                    print(decodedResponse)
                    completion(.success(decodedResponse))

                    
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
            }
            
        }.resume()
    }
    
    func getCart(completion: @escaping (Result<[Cart],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cart/\(self.userId)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = data {
                guard responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                do {
                    let cart = try JSONDecoder().decode([Cart].self, from: responseData)
                    completion(.success(cart))

                    
                } catch let jsonError {
                    completion(.failure(jsonError))
                }

            }
            
        }.resume()
    }
    
    
    func getMovie(id: String, completion: @escaping (Result<Movie,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/movie/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                let movie = try JSONDecoder().decode(Movie.self, from: data!)
                completion(.success(movie))
                print(movie)
                
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    }
    
    func getMovies(path: String, completion: @escaping (Result<[Movie],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)\(path)"
        print(url)
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")


        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(Response.self, from: data!)
                completion(.success(response.content))
                
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    }
        
    func getSale(id: String, completion: @escaping (Result<SaleDetails,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/sale/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            do {
                let sale = try JSONDecoder().decode(SaleDetails.self, from: data!)
                completion(.success(sale))
                print(sale)
                
            } catch let jsonError {
                completion(.failure(jsonError.localizedDescription as! Error))
            }
        }.resume()
    
    }
    
    func getSales(completion: @escaping (Result<[Sale],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/sale/customer/\(self.userId)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                let sales = try JSONDecoder().decode([Sale].self, from: data!)
                completion(.success(sales))
                print(sales)
                
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    
    }
    
    func getCast(id: String, completion: @escaping (Result<Star,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/star/\(id)"
        print(url)
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            do {
                let star = try JSONDecoder().decode(Star.self, from: data!)
                completion(.success(star))
                print(star)
                
            } catch let jsonError {
                completion(.failure(jsonError.localizedDescription as! Error))
            }
        }.resume()
    
    }
    
    
    func getCastMovie(id: String, completion: @escaping (Result<Star,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/star/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            do {
                let star = try JSONDecoder().decode(Star.self, from: data!)
                completion(.success(star))
                print(star)
                
            } catch let jsonError {
                completion(.failure(jsonError.localizedDescription as! Error))
            }
        }.resume()
    
    }
    
    func getMetaMovie(path: String, completion: @escaping (Result<[MovieMeta],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)\(path)"
        print(url)
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ResponseMeta.self, from: data!)
                completion(.success(response.content))
                print(response)
                
            } catch let jsonError {
                completion(.failure(jsonError.localizedDescription as! Error))
            }
        }.resume()
    
    }
        
}

class ContentDataSource: ObservableObject {
    
    @Published var items = [Movie]()
    @Published var isLoadingPage = false
    
    private var canLoadMorePages = true
    private var currentPage = 0
    private let pageSize = 10
    
    private var text = ""
    var query = ""

    init() {
        //loadMoreContent()
    }
    
    func setText(text: String, user: UserData) {
        if(text.count < 1) {
            self.text = "T"
            return
        }
        else {
            self.text = text
            self.items = [Movie]()
        }
        
        self.canLoadMorePages = true
        self.currentPage = 0
        loadMoreContent(user: user)
    }

   func loadMoreContent(user: UserData) {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        if(self.query.isEmpty) {
            return
        }

        isLoadingPage = true
    
        let url = "\(MyVariables.API_IP)/movie/\(self.query)/\(self.text)?limit=\(self.pageSize)&page=\(self.currentPage)"
        print(url)
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
    
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(user.token)", forHTTPHeaderField: "Authorization")
    
        URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Response.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.canLoadMorePages = !response.last
                self.isLoadingPage = false
                self.currentPage += 1
            })
            .map({ response in
                return self.items + response.content
            })
            .catch({ _ in Just(self.items) })
            .assign(to: &$items)
    }

}

class ContentDataSourceOrders: ObservableObject {
    
    @Published var items = [Sale]()
    @Published var isLoadingPage = false
    
    private var canLoadMorePages = true
    private var currentPage = 0
    private let pageSize = 10
    
    
    init() {
        //loadMoreContent()
    }

    func loadMoreContent(user: UserData) {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        isLoadingPage = true
    
        let url = "\(MyVariables.API_IP)/sale/customer/\(user.id)?limit=\(self.pageSize)&page=\(self.currentPage)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
    
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(user.token)", forHTTPHeaderField: "Authorization")
    
        URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ResponseOrders.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.canLoadMorePages = !response.last
                self.isLoadingPage = false
                self.currentPage += 1
            })
            .map({ response in
                return self.items + response.content
            })
            .catch({ _ in Just(self.items) })
            .assign(to: &$items)
    }

}




class ContentDataSourceMain: ObservableObject {
    
    @Published var items = [MovieMeta]()
    @Published var isLoadingPage = false
    
    private var canLoadMorePages = true
    private var currentPage = 0
    private let pageSize = 5
    
    
    init() {
        //loadMoreContent()
    }

    func loadMoreContent(user: UserData, path: String) {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        isLoadingPage = true
    
        let url = "\(MyVariables.API_IP)/\(path)?limit=\(self.pageSize)&page=\(self.currentPage)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
    
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(user.token)", forHTTPHeaderField: "Authorization")
    
        URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ResponseMeta.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.canLoadMorePages = !response.last
                self.isLoadingPage = false
                self.currentPage += 1
            })
            .map({ response in
                return self.items + response.content
            })
            .catch({ _ in Just(self.items) })
            .assign(to: &$items)
    }

}
