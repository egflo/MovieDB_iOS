//
//  LoginView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/28/21.
//

import SwiftUI
import KeychainAccess
import AlertToast
import JWTDecode

class PopoverViewModel: ObservableObject{
    
    @Published var show = false
    @Published var text = "Test"

}

class AlertViewModel: ObservableObject{
    
    @Published var show = false
    @Published var title = "Error"
    @Published var subtitle = "Subtitle"
   
    @Published var image = "exclamationmark.circle"
    @Published var color = Color.red

    func setError(title: String, subtitle: String) {
        self.image = "exclamationmark.circle"
        self.color = Color.red
        self.title = title
        self.subtitle = subtitle
        self.show = true
    }
    
    func setComplete(title: String, subtitle: String) {
        self.image = "exclamationmark.circle"
        self.color = Color.green
        self.title = title
        self.subtitle = subtitle
        self.show = true
    }

    func setSubtitle(subtitle: String) {
        self.subtitle = subtitle
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    /*
    @Published var alertToast: AlertToast {
        didSet{
            show.toggle()
        }
    }
    */
}


struct LoginView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @State private var email: String = ""
    @State private var password: String = ""
   
    @State private var title: String = "Error"
    @State private var message: String = ""
    @State private var showToast = false

    
    @State private var loading = false
    
    let verticalPaddingForForm = 30
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                VStack(spacing: CGFloat(verticalPaddingForForm)) {
                    Image(systemName: "film")
                        .resizable()
                        .frame(width: 100, height: 100).foregroundColor(.secondary)
                                    
                   HStack {
                        Image(systemName: "envelope.fill")
                           .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .shadow(radius: 8)
                    
                    HStack {
                        Image(systemName: "key")
                            .resizable()
                            .frame(width: 12, height: 20)
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
                            .foregroundColor(.gray)

                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .shadow(radius: 8)

                    
                    Button(action:  {
                            self.loading = true
                            authUser()
                            
                        
                    }) {
                        Text("Login").bold()
                            .padding()
                        
                        if(self.loading){
                            ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))

                        }
                        
                    }.frame(width: 150, height: 50)

                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    
              }.padding(.horizontal, CGFloat(verticalPaddingForForm))
                
            }.frame(maxWidth: 600)
            Spacer()
        }
        .navigationBarHidden(true)

    }
    
    func authUser() {
        NetworkManager.shared.authUser(username: email, password: password) { (result) in
            switch result {
            case .success(let userToken):
                DispatchQueue.main.async {
                    user.isLoggedin = true
                    user.id = userToken.id
                    user.username = userToken.username
                    //user.token = userToken.accessToken
                    //user.accessToken = userToken.accessToken
                                        
                    print("Response Token: \(userToken.accessToken)")
                    print("User Token: \(user.token)")
                    let keychain = Keychain(service: "com.dataflix")
                    keychain["id"] = String(userToken.id)
                    keychain["accessToken"] = userToken.accessToken
                    keychain["refreshToken"] = userToken.refreshToken
                    
                    self.loading = false
                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.setError(title: "Login Error", subtitle: error.localizedDescription)
                    self.loading = false
                }

            }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    let keychain = Keychain(service: "com.dataflix-token")

    
    var body: some View {
        NavigationView {
                        
             if !user.isLoggedin{
                   //return AnyView(LoginView())
                   //AnyView(LoginView())
                  LoginView()
              } else {
                 
             //ContextView(context: AnyView(MainView()))
                 MainView()
                     .transition(AnyTransition.opacity.animation(.easeInOut(duration: 1.0)))
                     //.transition(.move(edge: .trailing))
                     //.animation(Animation.linear(duration: 2))
                     .navigationBarHidden(true)

              }
           
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        
        .toast(isPresenting: $viewModel.show){

            //Choose .hud to toast alert from the top of the screen
            AlertToast(displayMode: .hud, type: .systemImage(viewModel.image, viewModel.color), title: viewModel.title, subTitle: viewModel.subtitle)
        }
        
    }
    
    
    func authToken() {
        let URL = "\(MyVariables.API_IP)/user/validate"
        
        NetworkManager.shared.getRequest(of:ResponseStatus<User>.self, url: URL){ (result) in
            switch result {
            case .success( _ ):
                DispatchQueue.main.async {
                    print("Valid Token")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.subtitle = error.localizedDescription
                    viewModel.show = true
                    user.isLoggedin = false
                }

            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
