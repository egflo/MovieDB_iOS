

import Foundation
import Alamofire
import KeychainAccess
import Combine
import Stripe


//https://medium.nextlevelswift.com/evolution-of-handling-api-response-with-alamofire-d326b211af41
//https://github.com/exyte/PopupView/blob/master/Example/Common/ContentView.swift
//https://github.com/callicoder/spring-boot-react-oauth2-social-login-demo/blob/master/react-social/src/app/App.js

struct MyVariables {
    static var API_IP = "http://localhost:8080"
    static var STRIPE_PUBLIC_KEY = ""
    
}


class UserData: ObservableObject {
    @Published var isLoggedin = false
    @Published var showToolBar = true
    @Published var id = 0
    @Published var username = ""
    @Published var token = ""
    @Published var qty = 0
    @Published var accessToken = ""
    
    func logout() {
        let keychain = Keychain(service: "com.dataflix")
        keychain["id"] = nil
        keychain["accessToken"] = nil
        keychain["refreshToken"] = nil
        
        self.isLoggedin = false
    }
}

enum APIError: Error {
    case invalidAuthorization
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
        case .invalidAuthorization:
            return NSLocalizedString("Unauthorized Access", comment: "Invalid Authentication")
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

struct Token: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

enum AuthError:Error {
    case missingToken
    case invalidToken
}


class NetworkManagerInterceptor: RequestInterceptor {
    
    let retryLimit = 5
    let retryDelay: TimeInterval = 10

    func refresh(completion: @escaping (Result<Token,Error>) -> Void) {
        let keychain = Keychain(service: "com.dataflix")
        let refreshToken = keychain["accessToken"]!
        
        let encoder = JSONEncoder()
        let requestRefresh = RefreshTokenRequest(refreshToken: refreshToken)
        let parameters = try! encoder.encode(requestRefresh)
        
        var request = URLRequest(url: URL(string: "\(MyVariables.API_IP)/user/refresh")!)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters

        AF.request(request)
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let response_data = try JSONDecoder().decode(Token.self, from: JSONSerialization.data(withJSONObject: data!))
                            completion(.success(response_data))
                            
                        } catch let error {
                            completion(.failure(error))
                        }
                    
                    case 401:
                        completion(.failure(APIError.invalidAuthorization))

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
    }


    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let keychain = Keychain(service: "com.dataflix")
        let accessToken = keychain["accessToken"]!

        guard urlRequest.url?.absoluteString.hasPrefix("\(MyVariables.API_IP)/user/refresh") == true else {
            /// If the request does not require authentication, we can directly return it as unmodified.
            return completion(.success(urlRequest))
        }
        var urlRequest = urlRequest

        /// Set the Authorization header value using the access token.
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            /// The request did not fail due to a 401 Unauthorized response.
            /// Return the original error and don't retry the request.
            return completion(.doNotRetryWithError(error))
        }
        
        if request.retryCount < retryLimit {
            completion(.retryWithDelay(retryDelay))
        }
        else {
            return completion(.doNotRetry)
        }

        refresh { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                let keychain = Keychain(service: "com.dataflix")
                keychain["accessToken"]! = token.accessToken
                /// After updating the token we can safely retry the original request.
                completion(.retry)
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
    }
}


func decode<T: Decodable>(_ data: Data, completion: @escaping ((T) -> Void)) {
    do {
        let model = try JSONDecoder().decode(T.self, from: data)
        completion(model)
    } catch {
        //failure(error.localizedDescription, level: .error)
        print("Decode Error")
    }
}


class NetworkManager {
    
    static let shared: NetworkManager = {
        return NetworkManager()
    }()
    
    let session: Session
    let interceptor = NetworkManagerInterceptor()

    var keychain: Keychain
    

    
    init() {
        session = Session(interceptor: interceptor)
        self.keychain = Keychain(service: "com.dataflix")

    }
    
    
   //https://forums.swift.org/t/how-to-pass-the-type-to-a-completion-handler-with-a-generic-type/25995
    func getRequest<T: Decodable>(of type: T.Type = T.self, url: String, completion: @escaping (Result<T,Error>) -> Void) {
        let accessToken = keychain["accessToken"] ?? ""
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        let headers: HTTPHeaders = [
           "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
        
        session.request(encoded_url!,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(T.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
                
    }
    
    func authUser(username: String, password: String, completion: @escaping (Result<UserToken,Error>) -> Void) {
        let accessToken = keychain["accessToken"] ?? ""

        let url = "\(MyVariables.API_IP)/user/auth"
        
        let parameters: Parameters = [
            "username": username,
            "password": password,
        ]
        

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(UserToken.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }
                        
                    case 401:
                        completion(.failure(APIError.invalidCredentials))

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })

    }
    
    
    func updateBookmark(id: String, userId: Int, completion: @escaping (Result<ResponseStatus<Bookmark>,Error>) -> Void) {
        let accessToken = keychain["accessToken"] ?? ""

        let url = "\(MyVariables.API_IP)/bookmark/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        struct UploadData: Codable {
            let customerId: Int
            let movieId: String
        }
        
        let parameters: Parameters = [
            "customerId": userId,
            "movieId": id,
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(encoded_url!,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(ResponseStatus<Bookmark>.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }
                        
                    case 400:
                        completion(.failure(APIError.invalidInventory))

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
        
    }
    
    
    func addCart(movieId: String, qty: Int, completion: @escaping (Result<ResponseStatus<Cart>,Error>) -> Void) {
        let accessToken = keychain["accessToken"] ?? ""
        let userId = keychain["id"] ?? ""

        let url = "\(MyVariables.API_IP)/cart/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        let parameters: Parameters = [
            "movieId": movieId,
            "userId": userId,
            "qty": qty
        ]
        
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(encoded_url!,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(ResponseStatus<Cart>.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }
                        
                    case 400:
                        completion(.failure(APIError.invalidInventory))

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
    }
    
    func deleteCart(id: Int, completion: @escaping (Result<ResponseStatus<Cart>,Error>) -> Void) {
        let accessToken = keychain["accessToken"] ?? ""

        let url = "\(MyVariables.API_IP)/cart/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(encoded_url!,
                   method: .delete,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(ResponseStatus<Cart>.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }
                        
                    case 400:
                        completion(.failure(APIError.invalidInventory))

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
        
    }
    
    
    
    func updateCart(id: Int, movieId: String, userId: Int, qty: Int, completion: @escaping (Result<ResponseStatus<Cart>,Error>) -> Void) {
        let accessToken = keychain["accessToken"] ?? ""

        let url = "\(MyVariables.API_IP)/cart/\(id)"
        
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        let parameters: Parameters = [
            "id": id,
            "movieId": movieId,
            "userId": userId,
            "qty": qty
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(encoded_url!,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(ResponseStatus<Cart>.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }
                        
                    case 400:
                        completion(.failure(APIError.invalidInventory))

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })

    }
    
    func deleteAddress(address: Address, completion: @escaping (Result<ResponseStatus<Address>,Error>) -> Void) {
        let accessToken = keychain["accessToken"] ?? ""
        let url = "\(MyVariables.API_IP)/address/\(address.id)"

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(url,
                   method: .delete,
                   parameters: nil,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(ResponseStatus<Address>.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })

    }
    
    func uploadEmail(email: Email, completion: @escaping (Result<ResponseStatus<User>,Error>) -> Void) {
        
        // Prepare URL
        let accessToken = keychain["accessToken"] ?? ""
        let url = "\(MyVariables.API_IP)/customer/email"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let parameters: Parameters = [
            "id": email.id,
            "password": email.password,
            "email": email.email,
            "newEmail": email.newEmail
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(url,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(ResponseStatus<User>.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
        
    }
    
    func uploadPassword(password: Password, completion: @escaping (Result<ResponseStatus<User>,Error>) -> Void) {

        // Prepare URL
        let accessToken = keychain["accessToken"] ?? ""
        let url = "\(MyVariables.API_IP)/customer/password"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let parameters: Parameters = [
            "id": password.id,
            "password": password.password,
            "newPassword": password.newPassword,
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(url,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(ResponseStatus<User>.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
        
    }
    
    
    func uploadPrimaryAddressId(userId: Int, primaryId: Int, completion: @escaping (Result<ResponseStatus<User>,Error>) -> Void) {
        
        // Prepare URL
        let accessToken = keychain["accessToken"] ?? ""

        let url = "\(MyVariables.API_IP)/customer/primary/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        
        let parameters: Parameters = [
            "id": userId,
            "primaryAddress": primaryId,
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(url,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(ResponseStatus<User>.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
                
    }
    
    func uploadCheckoutAddress(address: Address, completion: @escaping (Result<Checkout,Error>) -> Void) {
        // Prepare URL
        let accessToken = keychain["accessToken"] ?? ""
        let url = "\(MyVariables.API_IP)/checkout/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let parameters: Parameters = [
            "id": address.id,
            "firstname": address.firstname,
            "lastname": address.lastname,
            "street": address.street,
            "unit": address.unit,
            "city": address.city,
            "state": address.state,
            "postcode": address.postcode
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        session.request(url,
                    method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(Checkout.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
        

    }
        
    
    
    func uploadAddress(address: Address, insert: Bool, completion: @escaping (Result<ResponseStatus<Address>,Error>) -> Void) {
        // Prepare URL
        let accessToken = keychain["accessToken"] ?? ""
        let url = "\(MyVariables.API_IP)/address/"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let parameters: Parameters = [
            "id": address.id,
            "firstname": address.firstname,
            "lastname": address.lastname,
            "street": address.street,
            "unit": address.unit,
            "city": address.city,
            "state": address.state,
            "postcode": address.postcode
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        session.request(url,
                   method: (insert == true) ?.post : .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(ResponseStatus<Address>.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
        
    }
    
    func uploadOrder(order: ProcessOrder, completion: @escaping (Result<Sale,Error>) -> Void) {

        // Prepare URL
        let accessToken = keychain["accessToken"] ?? ""
        let url = "\(MyVariables.API_IP)/sale/"

        var request = URLRequest(url: URL(string: url)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
        
        request.httpBody = data
        
        session.request(url)
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let content = try JSONDecoder().decode(Sale.self, from:  data!)
                            completion(.success(content))
                            
                        } catch let error {
                            completion(.failure(error))
                        }

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
    }
    
    
    func preparePaymentIntent(amount: Double, currency: String, description: String, completion: @escaping (Result<STPPaymentIntentParams,Error>) -> Void) {
        
        // Prepare URL
        let accessToken = keychain["accessToken"] ?? ""
        let url = "\(MyVariables.API_IP)/checkout/charge"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        
        let parameters: Parameters = [
            "amount": amount,
            "currency": currency,
            "description": description,

        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(url,
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default,
                   headers: headers
            )
        
            .validate(statusCode: 200..<500)
            .response(completionHandler: { (response) in
                switch response.result {
                    case .success(let data):
                    switch response.response?.statusCode {
                    case 200:
                        do {
                            let paymentIntent = try JSONDecoder().decode(PaymentIntent.self, from:  data!)
                            completion(.success(STPPaymentIntentParams(clientSecret: paymentIntent.secret)))
                            
                        } catch let error {
                            completion(.failure(error))
                        }

                    default:
                        completion(.failure(APIError.invalidResponeCode))
                
                }
                case .failure(let error):
                    completion(.failure(error))

                }
            })
    }
    
}


class ContentDataSourceTest<T: Codable & Equatable>: ObservableObject {
    @Published var items = [T]()
    @Published var isLoadingPage = false
    @Published var endOfList = false
    
    private var canLoadMorePages = true
    private var currentPage = 0
    private let pageSize = 25
    
    var cancellable: Set<AnyCancellable> = Set()
    
    private var refreshToken: String
    private var accessToken: String

    init() {
        let keychain = Keychain(service: "com.dataflix")
        self.refreshToken = keychain["refreshToken"]!
        self.accessToken = keychain["accessToken"]!
    }
    
    func reset() {
        items.removeAll()
        currentPage = 0
        canLoadMorePages = true
        isLoadingPage = false
        endOfList = false
    }
    
    
    func shouldLoadMore(item : T) -> Bool{
        if let last = items.last
        {
            if item == last{
                return true
            }
            else{
                return false
            }
        }
        return false
    }
    
    func fetch(path: String) {
        guard canLoadMorePages else {
            return
        }
        
        isLoadingPage = true
        
        let url = "\(MyVariables.API_IP)/\(path)?limit=\(pageSize)&page=\(currentPage)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        var request = URLRequest(url: URL(string: encoded_url!)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Response<T>.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.canLoadMorePages = !response.last
                self.isLoadingPage = false
                self.currentPage += 1
                self.endOfList = response.content.isEmpty
            })
            .sink(receiveCompletion: { completion in
            }) { item in
                self.items.append(contentsOf: item.content)
            }
            .store(in: &cancellable)
    }
}


/*

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
            .decode(type: Response<Movie>.self, decoder: JSONDecoder())
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
*/
