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

//https://github.com/exyte/PopupView/blob/master/Example/Common/ContentView.swift
//https://github.com/callicoder/spring-boot-react-oauth2-social-login-demo/blob/master/react-social/src/app/App.js

struct MyVariables {
    //static var API_IP = "http://10.81.1.131:8080/moviedb_api"
    //static var API_IP = "https://dataflixapi.azurewebsites.net"
    static var API_IP = "http://10.81.1.111:8080"
    static var STRIPE_PUBLIC_KEY = "pk_test_51J3qCqBVPvYzs7uWw0nbrKwdIZWg0hmaYHEABbUirTZqQR2TftCxjMBRJhBlVIQbvYLTWDrUXt2WZnzVbY2BNfye0055McVHXT"
}

struct UserCart {
    static var items = [Cart]()
    private init() {}
}

class UserData: ObservableObject {
    //@Published var data: User 
    @Published var isLoggedin = false
    @Published var showToolBar = true
    @Published var id = 0
    @Published var username = ""
    @Published var token = ""
    @Published var qty = 0
}

enum APIError: Error {
    case invalidJSON
    case invalidJSONResponse
    case invalidResponeCode
    case invalidQty
    case invalidURL
    case invalidCredentials
    case invalidInventory
}


extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return NSLocalizedString("Unable to Encode Data Model", comment: "Invalid JSON")
        case .invalidJSONResponse:
            return NSLocalizedString("Invalid JSON From Recieved", comment: "Invalid JSON")
        case .invalidResponeCode:
            return NSLocalizedString("Invalide Respone Code", comment: "Non 200 Status Code")
        case .invalidQty:
            return NSLocalizedString("Invalid Quantity Selected", comment: "Invalid Qty")
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Bad URL")
        case .invalidCredentials:
            return NSLocalizedString("Incorrect Email/Password", comment: "Bad Username/Password")
        case .invalidInventory:
            return NSLocalizedString("Exceeds Current Inventory", comment: "Quantity exceeds Inventory")

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
    
    func getTopSearches(completion: @escaping (Result<[MovieMeta],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/rating/rated?limit=28"
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
                let decoded = try JSONDecoder().decode(ResponseMeta.self, from: data!)
                completion(.success(decoded.content))
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
                return
            }
        }.resume()
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
    
    func authToken(completion: @escaping (Result<ResponseStatus,Error>) -> Void) {
        let url = "\(MyVariables.API_IP)/user/validate"
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
                    let status = try JSONDecoder().decode(ResponseStatus.self, from: responseData)
                    completion(.success(status))
                    return
                    
                } catch {
                    completion(.failure(error))
                    return
                }
            }
            
        }.resume()
    }
    
    
    func getCartQty(completion: @escaping (Result<Int,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cart/qty/"
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

    
    
    func updateBookmark(id: String, completion: @escaping (Result<BookmarkResponse,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/bookmark/"
        print(url)
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
                
                do {
                    let decodedResponse = try JSONDecoder().decode(BookmarkResponse.self, from: responseData)
                    print("Response JSON data = \(decodedResponse)")
                    
                    completion(.success(decodedResponse))
                    return
       
                } catch {
                    completion(.failure(error))
                    return
                }

            }
        }.resume()
        
    }

    
    func getBookmark(id: String, completion: @escaping (Result<Bookmark,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/bookmark/\(id)"
        print(url)
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
                    
                   // if responseCode == 404 {
                   //     //Return Empty Bookmark (i.e not found)
                    //    completion(.success(Bookmark(id: 0, customerId: 0, movieId: id, created: 0)))
                    //    return
                   // }
                
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(BookmarkResponse.self, from: responseData)
                    print("Response JSON data = \(decodedResponse)")
                    
                    if(decodedResponse.success) {
                        completion(.success(decodedResponse.bookmark!))
                        return
                    }
                    
                    //Return Empty Bookmark (i.e not found)
                     //
                    completion(.success(Bookmark(id: 0, customerId: 0, movieId: id, created: 0)))
                    return

                } catch {
                    completion(.failure(error))
                    return
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
                //print("Response JSON data = \(sale)")
                completion(.success(sale))
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
                return
            }
        }.resume()
    }
    
    func uploadEmail(email: Email, completion: @escaping (Result<User,Error>) -> Void) {
        
        // Prepare URL
        let url = "\(MyVariables.API_IP)/customer/update/email/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "Post"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        guard let data = try? JSONEncoder().encode(email) else {
            completion(.failure(APIError.invalidJSON))
            return
         }
        
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                
                guard responseCode == 201 || responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let response = try? JSONDecoder().decode(User.self, from: responseData) {
                    print("Response JSON data = \(response)")
                    completion(.success(response))
                    return
                }
            }
        }.resume()
    }
    
    func uploadPrimaryAddressId(id: Int, completion: @escaping (Result<User,Error>) -> Void) {
        
        // Prepare URL
        let url = "\(MyVariables.API_IP)/customer/update/primary/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "Post"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        struct UploadData: Codable {
            let id: Int
            let primaryAddress: Int
        }
                
        let uploadDataModel = UploadData(id: userId, primaryAddress: id)
        
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
                if let response = try? JSONDecoder().decode(User.self, from: responseData) {
                    print("Response JSON data = \(response)")
                    completion(.success(response))
                    return
                }
            }
        }.resume()
    }
    
    func uploadCheckoutAddress(address: Address, completion: @escaping (Result<Checkout,Error>) -> Void) {
        // Prepare URL
        let url = "\(MyVariables.API_IP)/checkout/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "Post"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        guard let data = try? JSONEncoder().encode(address) else {
            completion(.failure(APIError.invalidJSON))
            return
         }
        
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                
                guard responseCode == 201 || responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let response = try? JSONDecoder().decode(Checkout.self, from: responseData) {
                    print("Response JSON data = \(response)")
                    completion(.success(response))
                    return
                }
            }
        }.resume()
        
    }
    
    func uploadPassword(password: Password, completion: @escaping (Result<User,Error>) -> Void) {
        // Prepare URL
        let url = "\(MyVariables.API_IP)/customer/update/password/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "Post"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        guard let data = try? JSONEncoder().encode(password) else {
            completion(.failure(APIError.invalidJSON))
            return
         }
        
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                
                guard responseCode == 201 || responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let response = try? JSONDecoder().decode(User.self, from: responseData) {
                    print("Response JSON data = \(response)")
                    completion(.success(response))
                    return
                }
            }
        }.resume()
        
    }
    
    func uploadAddress(address: Address, insert: Bool, completion: @escaping (Result<Address,Error>) -> Void) {
        // Prepare URL
        let url = "\(MyVariables.API_IP)/address/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = (insert == true) ? "Put" : "Post"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let uploadDataModel = Address(
                                      id: address.id,
                                      firstname: address.firstname,
                                      lastname: address.lastname,
                                      street: address.street,
                                      unit: address.unit,
                                      city: address.city,
                                      state: address.state,
                                      postcode: address.postcode)
        
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
                
                guard responseCode == 201 || responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let response = try? JSONDecoder().decode(Address.self, from: responseData) {
                    print("Response JSON data = \(response)")
                    completion(.success(response))
                    return
                }
            }
        }.resume()
        
    }
    
    func uploadOrder(order: ProcessOrder, completion: @escaping (Result<Sale,Error>) -> Void) {
        
        // Prepare URL
        let url = "\(MyVariables.API_IP)/sale/"
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
            let firstname: String
            let lastname: String
            let street: String
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
            let device: String
        }
        
        let uploadShippingModel = Shipping(customerId: order.customerId, firstname: order.address.firstname, lastname: order.address.lastname, street: order.address.street, unit: order.address.unit, city: order.address.city, state: order.address.state, postcode: order.address.postcode)
        
        let uploadDataModel = UploadData(total: order.total, subTotal: order.subtotal, salesTax: order.salesTax, customerId: order.customerId, stripeId: order.stripeId, shipping: uploadShippingModel, device: "ios")

        
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
                
                guard responseCode == 201 || responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let response = try? JSONDecoder().decode(Sale.self, from: responseData) {
                    print("Response JSON data = \(response)")
                    completion(.success(response))
                    return
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
                    return
                    
                } catch let error as NSError {
                    completion(.failure(error))
                    return
                }

            }
        }
        task.resume()
    }
    
    func getCheckout(completion: @escaping (Result<Checkout,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/checkout/"
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
                //print("Response JSON data = \(checkout)")
                completion(.success(checkout))
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
                return
            }
        }.resume()
    }
    
    func addCart(movieId: String, qty: Int, completion: @escaping (Result<Cart,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cart/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
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
                guard responseCode <= 201 else {
                    
                    if(responseCode == 400){
                        completion(.failure(APIError.invalidInventory))
                        return
                    }
                    
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let cart = try? JSONDecoder().decode(Cart.self, from: responseData) {
                    //print("Response JSON data = \(cart)")
                    completion(.success(cart))
                    return
                }
                else {
                    completion(.failure(APIError.invalidJSONResponse))
                    return
                }
            }
        }.resume()
    }
    
    func deleteCart(id: Int, completion: @escaping (Result<CartResponse,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cart/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        struct UploadData: Codable {
            let id: Int
        }
        
        let uploadDataModel = UploadData(id: id)
        
        
        guard let data = try? JSONEncoder().encode(uploadDataModel) else {
            completion(.failure(APIError.invalidJSON))
            return
         }
        

        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making DELETE request: \(error.localizedDescription)")
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                do {
                    //var dataString = String(data: responseData, encoding: .utf8) ?? ""
                    let decodedResponse = try JSONDecoder().decode(CartResponse.self, from: responseData)
                    completion(.success(decodedResponse))
                    return

                    
                } catch let jsonError {
                    completion(.failure(jsonError))
                    return
                }
            }
        }.resume()
    }

    func updateCart(id: Int, movieId: String, userId: Int, qty: Int, completion: @escaping (Result<CartResponse,Error>) -> Void) {
        
        if(qty <= 0) {
            completion(.failure(APIError.invalidQty))
            return
        }
        
        let url = "\(MyVariables.API_IP)/cart/"
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
            let movieId: String
            let userId: Int
            let qty: Int
        }
        
        let uploadDataModel = UploadData(
            id: id,
            movieId: movieId,
            userId: userId,
            qty: qty)
        
        
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
                    
                    if(responseCode == 400){
                        completion(.failure(APIError.invalidInventory))
                        return
                    }
                    
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let decdodedResponse = try? JSONDecoder().decode(CartResponse.self, from: responseData) {
                    completion(.success(decdodedResponse))
                    return
                }
            }
        }.resume()
    }
    
    func getUser(completion: @escaping (Result<User,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/customer/"
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
                    //var dataString = String(data: responseData, encoding: .utf8) ?? ""
                    let decodedResponse = try JSONDecoder().decode(User.self, from: responseData)
                    completion(.success(decodedResponse))
                    return

                    
                } catch let jsonError {
                    completion(.failure(jsonError))
                    return
                }
            }
            
        }.resume()
    }
    
    func getCart(completion: @escaping (Result<[Cart],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cart/"
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
                    return

                } catch let jsonError {
                    completion(.failure(jsonError))
                    return
                }

            }
            
        }.resume()
    }
    
    
    func getAddresses(completion: @escaping (Result<[Address],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/address/"
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
                    let addresses = try JSONDecoder().decode([Address].self, from: responseData)
                    completion(.success(addresses))
                    return

                } catch let jsonError {
                    completion(.failure(jsonError))
                    return
                }

            }
            
        }.resume()
    }
    
    func getMovie(id: String, completion: @escaping (Result<Movie,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/movie/\(id)"
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
                let movie = try JSONDecoder().decode(Movie.self, from: data!)
                completion(.success(movie))
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
                return
            }
        }.resume()
    }
    
    func getMovies(path: String, completion: @escaping (Result<[Movie],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)\(path)"
        print(url)
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
                let response = try JSONDecoder().decode(Response.self, from: data!)
                completion(.success(response.content))
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
                return
            }
        }.resume()
    }
        
    func getSale(id: String, completion: @escaping (Result<SaleDetails,Error>) -> Void) {
        
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
                completion(.success(sale))
                print(sale)
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
                return
            }
        }.resume()
    
    }
    
    func getSales(completion: @escaping (Result<[Sale],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/sale/"
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
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
                return
            }
        }.resume()
    
    }
    
    func getCast(id: String, completion: @escaping (Result<Star,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cast/\(id)"
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
                let star = try JSONDecoder().decode(Star.self, from: data!)
                completion(.success(star))
                print(star)
                
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    
    }
    
    
    func searchCast(name: String, completion: @escaping (Result<[Star],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cast/name/\(name)"
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
                let response = try JSONDecoder().decode(CastResponse.self, from: data!)
                completion(.success(response.content))
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    
    }
    
    func getCastMovie(id: String, completion: @escaping (Result<Star,Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)/cast/\(id)"
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
                let star = try JSONDecoder().decode(Star.self, from: data!)
                completion(.success(star))
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    
    }
    
    func getMetaMovie(path: String, completion: @escaping (Result<[MovieMeta],Error>) -> Void) {
        
        let url = "\(MyVariables.API_IP)\(path)"
        print(url)
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
                let response = try JSONDecoder().decode(ResponseMeta.self, from: data!)
                completion(.success(response.content))
                return
                
            } catch let jsonError {
                completion(.failure(jsonError))
                return
            }
        }.resume()
    
    }
    
    
    func deleteAddress(address: Address, completion: @escaping (Result<ResponseStatus,Error>) -> Void) {
        // Prepare URL
        let url = "\(MyVariables.API_IP)/address/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "Delete"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        

        guard let data = try? JSONEncoder().encode(address) else {
            completion(.failure(APIError.invalidJSON))
            return
         }
        
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                completion(.failure(error.localizedDescription as! Error))
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                
                guard  responseCode == 200 else {
                    completion(.failure(APIError.invalidResponeCode))
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let response = try? JSONDecoder().decode(ResponseStatus.self, from: responseData) {
                    print("Response JSON data = \(response)")
                    completion(.success(response))
                    return
                }
            }
        }.resume()
        
    }
        
}

class ContentDataSource: ObservableObject {
    
    @Published var items = [Movie]()
    @Published var isLoadingPage = false
    @Published var last = false
    
    private var canLoadMorePages = true
    private var currentPage = 0
    private let pageSize = 14
    
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
                self.last = response.last
            })
            .map({ response in
                return self.items + response.content
            })
            .catch({ _ in Just(self.items) })
            .assign(to: &$items)
    }

}

class ContentDataSourceReviews: ObservableObject {
    
    @Published var items = [Review]()
    @Published var isLoadingPage = false
    
    public var totalElements = 0
    private var canLoadMorePages = true
    private var currentPage = 0
    private let pageSize = 5
    
    
    init() {
        //loadMoreContent()
    }

    func loadMoreContent(user: UserData, movie: Movie) {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        isLoadingPage = true
    
        let url = "\(MyVariables.API_IP)/review/movie/\(movie.id)?limit=\(self.pageSize)&page=\(self.currentPage)"
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
            .decode(type: ResponseReviews.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.canLoadMorePages = !response.last
                self.totalElements = response.totalElements
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
    
        let url = "\(MyVariables.API_IP)/sale/?limit=\(self.pageSize)&page=\(self.currentPage)"
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
