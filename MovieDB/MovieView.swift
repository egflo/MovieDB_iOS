//
//  MovieView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/16/21.
//

import Foundation
import SwiftUI
import URLImage
import SDWebImageSwiftUI
import SPAlert

struct DropDownMovie: View {
    @Binding var movie: Movie

    @State var expand = false

    var body: some View {
        VStack {
            VStack(alignment: .leading, content: {
                
                HStack {
                    Text("More Details").font(.subheadline).bold()
                    
                    Image(systemName: expand ? "chevron.up" : "chevron.down")
                        .font(.system(size: 20))
                }
                .onTapGesture {
                    self.expand.toggle()
                }
            })
            .frame(width: (UIScreen.main.bounds.width), height: 40)
            .background(Color(.systemGray6))
            .foregroundColor(Color.blue)
            
            if expand {
                VStack{
                    
                    if let unwrapped = movie.language {
                        
                        Text("Language(s): " + unwrapped)
                            .padding(.bottom, 10)
                            .frame(width: (UIScreen.main.bounds.width - 50), alignment: .topLeading)
                        
                    }
                    
                    if let unwrapped = movie.writer {
                        
                        Text("Writer(s): " + unwrapped)
                            .padding(.bottom, 10)
                            .frame(width: (UIScreen.main.bounds.width - 50), alignment: .topLeading)
                        
                    }
                    
                    if let unwrapped = movie.awards {
                        
                        Text("Awards(s): " + unwrapped)
                            .padding(.bottom, 10)
                            .frame(width: (UIScreen.main.bounds.width - 50), alignment: .topLeading)
                        
                    }
                    
                    if let unwrapped = movie.boxOffice {
                        
                        Text("Box Office: " + unwrapped)
                            .padding(.bottom, 10)
                            .frame(width: (UIScreen.main.bounds.width - 50), alignment: .topLeading)
                        
                    }
                    
                    if let unwrapped = movie.production {
                        
                        Text("Production: " + unwrapped)
                            .padding(.bottom, 10)
                            .frame(width: (UIScreen.main.bounds.width - 50), alignment: .topLeading)
                        
                    }
                    
                    if let unwrapped = movie.country {
                        
                        Text("Country: " + unwrapped)
                            .padding(.bottom, 10)
                            .frame(width: (UIScreen.main.bounds.width - 50), alignment: .topLeading)
                        
                    }
                    
                }.padding(.top, 10)
               // .transition(.move(edge: .top))
              //  .animation(Animation.linear(duration: 2))
                    
            }
        }.frame(width: UIScreen.main.bounds.width)

    }
    
}



//Modified From: https://www.hackingwithswift.com/books/ios-swiftui/adding-a-custom-star-rating-component
struct RatingRow: View {
    @Binding var movie: Movie
    
    var maximumRating = 5

    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.yellow
    
    
    var body: some View {
        HStack {

            ForEach(1..<maximumRating + 1) { number in
                self.image(for: number)
                    .foregroundColor(number > rate() ? self.offColor : self.onColor)
            }
            
            Text(numVotes())
            
        }
    }
    
    func rate() -> Int {
        //double five_star_rating = float_rating * .5;
        //double rounded = (double) Math.round(five_star_rating * 100) / 100;
        
        if let unwrapped = self.movie.ratings {
            
            let number = unwrapped.rating * 0.5
            return Int(number)
        } else {
            return 0
        }
    }
    
    func numberFormat(number: Int) -> String  {
        if(number < 1000) {
            return String(number)
        }
        let x = log(Double(number))
        let y = log(1000.0)
        let exp = Int(x/y)
        let z = pow(1000,exp)
        let v = Decimal(number)/z
        
        let lst = ["K","M","G","T","P"]
        
        return String(format: "%.1f \(lst[exp-1])", Float(truncating: v as NSNumber))
    }
    
    func numVotes() -> String {
        
        if let unwrapped = self.movie.ratings {
            
            let number = Int(unwrapped.numVotes)
            let num_format = numberFormat(number: number)
            
            return "(\(num_format) Votes)"
            
        } else {
            return ""
        }
    }
    
    func image(for number: Int) -> Image {
        if number > rate() {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

struct GenreRow: View {
    @Binding var movie: Movie
    @State var isLinkActive = false    
    
    var body: some View {
        HStack {
            ForEach(movie.genres ?? [Genre](), id: \.name) { genre in
                    VStack{
                        NavigationLink(destination: GenreView(genre: genre)){
                            Text(genre.name)
                                .padding(.trailing, 10)
                                .padding(.leading, 10)
                                //.font(.system(size: 25, weight: .bold, design: .default))
                                .font(.system(size: 25, design: .default))
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }.frame(height: 25)
                            .padding(.trailing, 5)
                            .padding(.leading, 5)

                    }
               }
        }
    }

}


struct CastRow: View {
    @Binding var movie: Movie
    @State var cast = [Cast]()
    
    var body: some View {
        VStack { //geometry in

            List {
                    Section(header:
                        VStack(alignment: .center) {
                            Text("Cast & Crew")
                                .font(.subheadline).bold()
                                .foregroundColor(Color.blue)
                                .textCase(.none)

                        })
                    {
                    
                    ForEach(movie.cast ?? [Cast](), id: \.starId) { cast in
                        let c = CastDecode(cast: cast)
                        
                        NavigationLink(destination: CastView(cast: cast)) {
                            HStack {
                                VStack {
                                    WebImage(url: URL(string: c.photo()))
                                            .resizable()
                                            .renderingMode(.original)
                                            .placeholder(Image(systemName: "person"))
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(8)
                                    
                                }
                                .frame(width: 30, height: 60)
                                
                                VStack(alignment: .leading) {
                                    
                                    Text(c.name())
                                    Text(c.subStringCast()).font(.subheadline).foregroundColor(.gray)

                                }
                                Spacer()
                                Text("Details")
                            }
                        }

                    }

                }//.frame(width: (geometry.size.width) - 33)//.background(Color.blue)


            }
            .listStyle(GroupedListStyle())

            .onAppear(perform: {
                UITableView.appearance().isScrollEnabled = false
            })
            
        }.frame(height: (UIScreen.main.bounds.height - 33))
        //.frame(height: (UIScreen.main.bounds.height - 33))
        //.frame(width: (UIScreen.main.bounds.width - 33), height: (CGFloat(cast.count) * 80))
        //.listStyle(GroupedListStyle())

        //.onAppear(perform: {
        //    UITableView.appearance().isScrollEnabled = false
       // })
    }
}

struct iPhoneMovieView: View {
    @Binding var movie: Movie
    @EnvironmentObject var user: User
    
    var body: some View {
        let m = MovieDecode(movie:movie)
        
        HStack{
            WebImage(url: m.posterURL())
                .resizable()
                .renderingMode(.original)
                .placeholder(Image("no_image"))
                .aspectRatio(contentMode: .fit)
                .cornerRadius(8)
                .frame(width: 150, height: 200)

            VStack (alignment: .leading){
                let reviews = RatingDecode(movie: movie)
                let imdb = reviews.getIMDB()
                let rotten = reviews.getRottenTomatoes()
                let meta = reviews.getMetaCritic()
                
                HStack () {
                    Image(rotten.0)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text(rotten.1).font(.system(size: 10))
                    
                }
                
                HStack {
                    Image("imdb")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 30)
                    Text(imdb).font(.system(size: 10))
                }

                HStack {
                    Text(meta.1).foregroundColor(Color.white).bold()
                        .background(Rectangle()
                        .fill(meta.0)
                        .frame(width: 40, height: 40)
                        .cornerRadius(8))
                    
                }.frame(width: 40, height: 40)
           
            }
            .frame(width: 80, height: 200)
            
        }.frame(width: 250, height: 200)
        
        HStack{
            Text(m.title()).font(.title)
            
            Button(action: {
                print("Bookmark button pressed...")
                user.bookmark(movie: movie)
                
            })
            {
                   Image(systemName: "\(user.bookmarkStatus(movie:movie))")
                        .font(.system(size: 25.0))
                        .foregroundColor(Color.blue)
              
            }
        }.padding(.bottom,5)

        
        Text(m.director()).padding(.bottom,5)
        
        Text(m.subString()).font(.subheadline).foregroundColor(.gray).padding(.bottom,5)

        Text(m.plot()).frame(width: 350, height: 100).padding(.bottom,5)
    
        GenreRow(movie: $movie).padding(.bottom,10)
        
        // RatingRow(movie: movie).padding(.bottom,20)
        
        DropDownMovie(movie: $movie)
    }

}

struct iPadMovieView: View {
    @Binding var movie: Movie
    @EnvironmentObject var user: User
    
    var body: some View {
        let m = MovieDecode(movie:movie)

        HStack(alignment: .top){
            WebImage(url: URL(string: m.poster()))
                .resizable()
                .renderingMode(.original)
                .placeholder(Image("no_image"))
                .aspectRatio(contentMode: .fit)
                .cornerRadius(8)
                .frame(width: 290, height: 400)
                //.border(Color.red)
            
            ScrollView {
            VStack(alignment: .leading){
                
                HStack {
                    
                    Text(m.title())
                        .font(.system(size: 40.0))
                        .bold()

                    
                    Button(action: {
                        print("Bookmark button pressed...")
                        user.bookmark(movie: movie)
                        
                    })
                    {
                           Image(systemName: "\(user.bookmarkStatus(movie:movie))")
                                .font(.system(size: 35.0))
                                .foregroundColor(Color.blue)
                      
                    }
                    
                }.padding(.bottom,5)


                RatingRow(movie:$movie)
                    .padding(.bottom,5)


                Text("Director: \(m.director())")
                    .font(.system(size: 20.0))
                    .foregroundColor(.gray)
                    .padding(.bottom,5)

                Text(m.subString())
                    .font(.system(size: 20.0))
                    .foregroundColor(.gray)
                    .padding(.bottom,5)
                    //.frame(width: (UIScreen.main.bounds.width-300), alignment: .leading)
                              
                Text(m.plot())
                    .font(.system(size: 20.0))
                    .foregroundColor(.gray)
                    .padding(.bottom,5)
                
                
                Text("Country: \(m.country())")
                    .font(.system(size: 20.0))
                    .foregroundColor(.gray)
                    .padding(.bottom,5)
                              
                
                Text("Language(s): \(m.language())")
                    .font(.system(size: 20.0))
                    .foregroundColor(.gray)
                    .padding(.bottom,5)
                
                
                Text("Awards: \(m.award())")
                    .font(.system(size: 20.0))
                    .foregroundColor(.gray)
                    .padding(.bottom,5)
                
                Text("Box Office: \(m.boxOffice())")
                    .font(.system(size: 20.0))
                    .foregroundColor(.gray)
                    .padding(.bottom,5)
                
                Text("Production: \(m.production())")
                    .font(.system(size: 20.0))
                    .foregroundColor(.gray)
                    .padding(.bottom,5)
                
            }.frame(width: (UIScreen.main.bounds.width-350))
                
            }
            
        }.frame(width: (UIScreen.main.bounds.width-33), height: 400)//.border(Color.blue)
        
        HStack {
            HStack {
                let reviews = RatingDecode(movie: movie)
                let imdb = reviews.getIMDB()
                let rotten = reviews.getRottenTomatoes()
                let meta = reviews.getMetaCritic()
                                            
                
                Image(rotten.0)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                Text(rotten.1)
                    .font(.system(size: 10)).bold()
                
                
                Image("imdb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 30)
                Text(imdb)
                    .font(.system(size: 10)).bold()
                    .padding(.trailing, 10)
                
                
                Text(meta.1)
                    .foregroundColor(Color.white).bold()
                    .background(Rectangle()
                    .fill(meta.0)
                    .frame(width: 40, height: 40)
                    .cornerRadius(8))
                
            }.frame(width: 290, height: 50).offset(x:0)//.border(Color.red)
            
            HStack {
                GenreRow(movie: $movie)
            }.padding(.leading, 10)
            
            Spacer()

            
        }.frame(width: (UIScreen.main.bounds.width-33), height: 50)//.border(Color.blue)

    }
}

struct MovieView: View {
    @EnvironmentObject var user: User
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var movie_api: MovieDB_API

    @State var movie: Movie
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false

    @State private var addedToCartAlert = false

    let height = (UIScreen.main.bounds.height - 50)

    var body: some View {
        
            ZStack{
              ScrollView{
                VStack {
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        // Available Idioms - .pad, .phone, .tv, .carPlay, .unspecified
                        // Implement your logic here
                        if self.sizeClass == .compact {
                            iPhoneMovieView(movie: $movie)
                        } else {
                            iPadMovieView(movie: $movie)
                        }
                    }
                    else {
                        
                        iPhoneMovieView(movie: $movie)
                                                
                    }
                    
                    CastRow(movie: $movie)
                    
                }.offset(y:10)
            
               }
               .onAppear(perform: {
                    self.loadMovie(id: movie.id)
               })
           
               .navigationBarHidden(false)
               .navigationBarTitle(Text("\(movie.title)"), displayMode: .inline)

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
                            let count = user.getCartCount()
                            
                            if(count == 0) {
                                
                                Image(systemName: "cart").imageScale(.large)

                            }
                            else{
                                ZStack {
                                    Image(systemName: "cart").imageScale(.large)
                                    Text("\(user.getCartCountStr())")
                                        .foregroundColor(Color.black)
                                        .background(Capsule().fill(Color.orange).frame(width:30, height:20))
                                        .offset(x:20, y:-10)

                                }
                                
                            }
                           
                       }
                   }
                 }
               }
                
                GeometryReader {geometry in
                    Button(action: {
                        print("Add button pressed...")
                        //let qty = user.cart[movie] ?? 0
                        //user.cart[movie] = qty+1
                        user.addToCart(movie: movie)
                        addedToCartAlert = true
                    })
                    {
                        HStack {
                            Image(systemName: "cart.badge.plus")
                                .font(.title)
                            Text("Add to Bag")
                                .fontWeight(.semibold)
                                .font(.title)
                        }
                        .padding(12)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)

                    }
                    .spAlert(isPresent: $addedToCartAlert, message: "Added To Cart", duration:2.0, dismissOnTap: true, layout: .init())
                    .offset( x:(geometry.size.width/2)-100, y: geometry.size.height-70)

                }

            }

    }
    
    
    func loadMovie(id: String) {
        
        let url = "\(MyVariables.API_IP)/movie/\(id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(Movie.self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        self.movie = decodedResponse

                    }
                    
                    // everything is good, so we can exit
                    return
                }
            }
        
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
    
}

