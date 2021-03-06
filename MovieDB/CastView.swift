//
//  CastView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/16/21.
//

import SwiftUI
import URLImage
import SDWebImageSwiftUI
import AlertToast

struct DropDown: View {
    var headline: String
    var text: String

    @State var expand = false

    var body: some View {
        
        VStack(alignment: .leading, content: {
            
            HStack {
                Text(headline).font(.subheadline).bold()
                
                Image(systemName: expand ? "chevron.up" : "chevron.down")
                    .font(.system(size: 20))
            }

        })
        .frame(width: (UIScreen.main.bounds.width), height: 40)
        .background(Color(.systemGray6))
        .foregroundColor(Color.blue)
        .onTapGesture {
            self.expand.toggle()
        }
        
        if expand {
            Text(self.text)
                .padding(.bottom, 5)
                .frame(width: (UIScreen.main.bounds.width - 50), alignment: .topLeading)
            
        }
    }
    
}

struct CastMovieRow: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @State var cast: Star
    let rowHeight = 65

    var body: some View {
        VStack {
            
            HStack {
                Text("Filmography").font(.subheadline).bold()
            }
            .frame(width: (UIScreen.main.bounds.width), height: 40)
            .background(Color(.systemGray6))
            .foregroundColor(Color.blue)
                            
            ForEach(cast.movies, id: \.uuid) { cast_info in
                
                    let movie = cast_info.movie!
                    let m = MovieDecode(movie: cast_info.movie!)

                    NavigationLink(destination: MovieView(movieId: movie.id)) {
                        HStack {
                            VStack {
                                WebImage(url: URL(string: m.poster()))
                                        .resizable()
                                        .renderingMode(.original)
                                        .placeholder(Image("no_image"))
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(8)
                                
                            }
                            .frame(width: 30, height: 60)
                            
                            VStack(alignment: .leading) {
                                
                                Text(m.title())
                                    .foregroundColor(Color.blue)

                                Text(m.subString()).font(.subheadline).foregroundColor(.gray)


                            }
                            Spacer()
                            Text("Details")
                                .foregroundColor(Color.blue)

                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 15))
                                .foregroundColor(Color.gray)
                        }
                    }

                }
                //.frame(height: UIScreen.main.bounds.height)
                .frame(height: CGFloat(rowHeight))
                .padding(.leading, 15)
                .padding(.trailing, 15)
                //.listStyle(GroupedListStyle())
                .listStyle(PlainListStyle())

                .onAppear(perform: {
                    UITableView.appearance().isScrollEnabled = false
                })
                
            }
            

        }

    }
    


struct iPhoneCastView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    @State var cast: Star

    var body: some View {
        VStack {
            
                
                let c = StarDecode(cast: cast)
                
                VStack {

                    WebImage(url: URL(string: c.photo()))
                        .resizable()
                        .renderingMode(.original)
                        .placeholder(Image("no_image"))
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
            
                }.frame(width: (UIScreen.main.bounds.width - 33), height: 250)
                
                Text(c.name()).font(.title).bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            
                Text(c.subString()).font(.subheadline).foregroundColor(.gray)//.padding(.bottom,10)
         
                Text(c.birthDetails()).padding(.bottom,5).frame(width: (UIScreen.main.bounds.width - 33))
            
                DropDown(headline: "Biography", text: c.bio())//.padding(.bottom,10)
                
            }
            


        }
        
    
}

struct iPadCastView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @State var cast: Star

    var body: some View {
        
        VStack {
            
                
                let c = StarDecode(cast: cast)

                HStack(alignment: .top){
                    WebImage(url: URL(string: c.photo()))
                        .resizable()
                        //.renderingMode(.original)
                        .placeholder(Image("no_image"))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 290, height: 400)
                        .clipped()
                        //.aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                    
                    ScrollView {
                        VStack(alignment: .leading){
                            
                            HStack {
                                Text("\(c.name()) \(c.subString())")
                                    .font(.system(size: 30.0)).bold()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                    
                                
                            }.padding(.bottom,5)

                            let birth_details = c.birthDetails()
                            
                            if(birth_details.count != 0) {
                                
                                Text(c.birthDetails())
                                    .font(.system(size: 20.0))
                                    .foregroundColor(.gray)
                                    .padding(.bottom,5)
                                
                            }

                            Text(c.bio())
                                .font(.system(size: 20.0))
                                .foregroundColor(.gray)
                                .padding(.bottom,5)


                            
                        }.frame(width: (UIScreen.main.bounds.width-350), alignment: .leading)
                        
                    }
                    
                }.frame(width: (UIScreen.main.bounds.width-33), height: 400)
                    .padding(.bottom, 5)
                
                
            }
            
            
        }
        

}

struct CastView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    
    var castId: String
    @State var data: Star?
    
    var body: some View {
        VStack {
            if let cast = data {
                
                ScrollView(.vertical, showsIndicators: false) {
                  if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                      iPhoneCastView(cast: cast)
                       CastMovieRow(cast: cast)

                  }
                  else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                      
                      iPhoneCastView(cast: cast)
                       CastMovieRow(cast: cast)
                  }
                  else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                      
                      iPadCastView(cast: cast)
                      CastMovieRow(cast: cast)

                  }
                  
              }
                
            }
            else {
                ProgressView()
            }
            
        }
        .onAppear(perform: {getStarData()})
        .toast(isPresenting: $viewModel.show){

            //Choose .hud to toast alert from the top of the screen
            AlertToast(displayMode: .hud, type: .error(Color.red), title: viewModel.title, subTitle: viewModel.subtitle)

        }
        .navigationBarHidden(false)
        .navigationBarTitle(Text("\(castId)"), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
    }
    
    
    func getStarData() {
        let URL = "\(MyVariables.API_IP)/cast/\(castId)"

        NetworkManager.shared.getRequest(of: Star.self, url: URL){ (result) in
            switch result {
            case .success(let star):
                DispatchQueue.main.async {
                    self.data = star
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }

}
