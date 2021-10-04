//
//  MovieView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/16/21.
//

import SwiftUI
import URLImage
import SDWebImageSwiftUI
import SPAlert
import AlertToast

struct BookmarkView: View {
    @EnvironmentObject var user: UserData

    @Binding var movie: Movie
    @State var bookmark: Bookmark?

    var body: some View {
        VStack {
            
            if let bookmark = bookmark {
                
                Button(action: {
                    print("Bookmark button pressed...")
                    updateBookmark()
                    
                })
                {
                    Image(systemName:(bookmark.id == 0) ? "bookmark" : "bookmark.fill")
                            .font(.system(size: 25.0))
                            .foregroundColor(Color.blue)
                  
                }
            }
            
            else {
                
                Image(systemName: "bookmark.slash")
                     .font(.system(size: 25.0))
                     .foregroundColor(Color.blue)
                
            }
            
            
        }.onAppear(perform: {getBookmarkData()})

    }
    
    func getBookmarkData() {
        API(user: user).getBookmark(id: movie.id) { (result) in
            switch result {
            case .success(let bookmark):
                DispatchQueue.main.async {
                    self.bookmark = bookmark
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateBookmark() {
        API(user: user).updateBookmark(id: movie.id) { (result) in
            switch result {
            case .success(let bookmark):
                DispatchQueue.main.async {
                    self.bookmark = bookmark
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct DropDownMovie: View {
    @Binding var movie: Movie

    @State var expand = false
    
    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        VStack {
            VStack(alignment: .leading, content: {
                
                HStack {
                    Text("More Details").font(.subheadline).bold()
                    
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
                VStack{
                    if let unwrapped = movie.language {
                        
                        Group {
                            Text("Language(s): ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()
                    }
                    
                    if let unwrapped = movie.writer {
                        
                        Group {
                            Text("Writer(s): ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()

                    }
                    
                    if let unwrapped = movie.awards {

                        Group {
                            Text("Awards(s): ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()
                    }
                    
                    if let unwrapped = movie.boxOffice {
                        
                        Group {
                            Text("Box Office: ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()

                    }
                    
                    if let unwrapped = movie.production {
                        
                        Group {
                            Text("Production: ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()

                    }
                    
                    if let unwrapped = movie.country {
                        
                        Group {
                            Text("Country: ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()
                    }
                    
                }.padding(.top, 10)
                    
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
            
            Text(numVotes()).bold().foregroundColor(.white).shadow(radius: 5)
            
        }
    }
    
    func rate() -> Int {
        //double five_star_rating = float_rating * .5;
        //double rounded = (double) Math.round(five_star_rating * 100) / 100;
        
        if let unwrapped = self.movie.ratings {
            
            let number = unwrapped.rating! * 0.5
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
            
            let number = Int(unwrapped.numVotes!)
            let num_format = numberFormat(number: number)
            
            return "(\(num_format))"
            
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
        VStack {
            HStack {
                ForEach(movie.genres, id: \.name) { genre in
                        VStack{
                            NavigationLink(destination: GenreView(genre: genre)){
                                Text(genre.name)
                                    .padding(7)
                                    .font(.system(size: 25, design: .default))
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                   }
            }
        }
    }
}


struct CastRow: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight

    @Binding var movie: Movie
    
    var body: some View {
        VStack {
            HStack {
                Text("Cast & Crew").font(.subheadline).bold()
            }
            .frame(width: (UIScreen.main.bounds.width), height: 40)
            .background(Color(.systemGray6))
            .foregroundColor(Color.blue)

            List(movie.cast, id: \.starId) { cast in
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
                                .foregroundColor(Color.blue)

                            Text(c.subStringCast()).font(.subheadline).foregroundColor(.gray)

                        }
                        Spacer()
                        Text("Details")
                            .foregroundColor(Color.blue)

                    }
                }

            }

        }
        .frame(height: UIScreen.main.bounds.height)
        //.listStyle(GroupedListStyle())
        .listStyle(PlainListStyle())

        .onAppear(perform: {
            UITableView.appearance().isScrollEnabled = false
        })
            
    }
}



struct BackgroundView: View {
    @EnvironmentObject var user: UserData

    @Binding var movie: Movie
        
    let width = (UIScreen.main.bounds.width)

    var body: some View {
        let m = MovieDecode(movie:movie)
        
        ZStack (alignment: .bottomLeading){
            WebImage(url: URL(string: m.background()))
                    .placeholder(Image(systemName: "livephoto.slash"))
                    .resizable()
                    .frame(width: width, height: 250, alignment: .center)
                    .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text(m.title()).font(.system(size: 25)).bold().foregroundColor(.white).shadow(radius: 5)

                    BookmarkView(movie: $movie)
                }
                
                Text(m.subString()).font(.subheadline).bold().foregroundColor(.white).shadow(radius: 5)
                    .padding(.bottom, 1)

                RatingRow(movie: $movie)

            }
            .padding(.bottom,15)
            .padding(.leading,10)
            
        }
        .frame(width: width, height: 250, alignment: .center)
        
        let reviews = RatingDecode(movie: movie)
        let imdb = reviews.getIMDB()
        let rotten = reviews.getRottenTomatoes()
        let meta = reviews.getMetaCritic()
        
        
        HStack {
            
            imdb.padding(.trailing, 10)
            
            rotten.padding(.trailing, 10)
            
            meta
            
        }.frame(width: width - 33)
    }
}


struct iPhonePortraitMovieView: View {
    @Binding var movie: Movie
    
    let width = (UIScreen.main.bounds.width - 33)
    
    var body: some View {
        let m = MovieDecode(movie:movie)
        VStack {
            
            if (m.background().isEmpty) {
                ZStack {
                   // WebImage(url: m.posterURL())
                    Image("background")
                        .resizable()
                        //.placeholder(Image("background"))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 410)
                        .clipped()
                        .blur(radius: 6)
                    
                    VStack {
                        HStack{
                            WebImage(url: m.posterURL())
                                .resizable()
                                .renderingMode(.original)
                                .placeholder(Image("no_image"))
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(8)
                                .frame(width: 140, height: 200)

                            VStack (alignment: .leading){
                                let reviews = RatingDecode(movie: movie)
                                let imdb = reviews.getIMDB()
                                let rotten = reviews.getRottenTomatoes()
                                let meta = reviews.getMetaCritic()
                                
                                BookmarkView(movie: $movie).padding(.leading, 2)
                                
                                VStack {
                                    rotten
                                }.padding(.top, 5)
                                
                                
                                VStack {
                                    imdb
                                }.padding(.leading, 2)

                            
                                VStack {
                                    meta
                                }.padding(.leading, 2)
                                    .padding(.top, 5)

                           
                            }
                            .frame(height: 200, alignment: .leading)
                                //.frame(minWidth: 150, maxWidth: 150, minHeight: 200, maxHeight: 200, alignment: .leading)
                            
                            
                        }.frame(height: 200)
                        //.frame(width: 250, height: 200)
                        
                        VStack {
                            Text(m.title())
                                .font(.system(size: 40.0)).bold()
                                .shadow(radius: 5)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)

                            Text(m.director()).padding(.bottom,5)
                            
                            //Text(m.subString()).font(.subheadline).foregroundColor(.gray).padding(.bottom,5)
                            
                            m.subheadline()
                            
                        }.frame(width:width)
                        
                    }
                    
                }
                .frame(width: UIScreen.main.bounds.width, height: 410)
                
                VStack {

                    Text(m.plot())
                        .padding(.bottom,5)
                        //.frame(height: 100)
                                
                }.frame(width:width)
            }
            else {
                
                BackgroundView(movie: $movie)
                
                VStack {

                    Text(m.plot())
                        .padding(.bottom,5)
                                
                }.frame(width:width)
                
            }
        }
    }
}

struct iPhoneLandscapeMovieView: View {
    @Binding var movie: Movie
    
    let width = (UIScreen.main.bounds.width)
    
    var body: some View {
        let m = MovieDecode(movie:movie)
        VStack {
                
            HStack{
                WebImage(url: m.posterURL())
                    .resizable()
                    .renderingMode(.original)
                    .placeholder(Image("no_image"))
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .frame(width: 160, height: 220)
                
                VStack (alignment: .leading){
                    Text(m.title()).font(.title)
                    
                    Text(m.subString()).font(.subheadline).foregroundColor(.gray)
                    
                    Text(m.director())

                    HStack {
                        let reviews = RatingDecode(movie: movie)
                        let imdb = reviews.getIMDB()
                        let rotten = reviews.getRottenTomatoes()
                        let meta = reviews.getMetaCritic()
                        
                        BookmarkView(movie: $movie)
                            .padding(.trailing, 10)
                        
                        imdb.padding(.trailing, 10)
                        
                        rotten.padding(.trailing, 10)
                        
                        meta
                    }

                    Text(m.plot())
                                
                }
                
            }
            .frame(width: width, height: 200)
            
        }
    }
}

struct iPadMovieView: View {
    @Binding var movie: Movie
    @EnvironmentObject var user: UserData
    
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        let m = MovieDecode(movie:movie)

    
        //if (m.background().isEmpty) {
        //Disabled - Background looks better
        if (false) {
            HStack(alignment: .top){
                WebImage(url: URL(string: m.poster()))
                    .resizable()
                    .renderingMode(.original)
                    .placeholder(Image("no_image"))
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .frame(width: 290, height: 400)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(m.title())
                            .font(.system(size: 35))
                            .bold()
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)

                        BookmarkView(movie: $movie)
                        
                        Spacer()
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)   // << here !!
                    .padding(.bottom,5)


                    Text(m.subString())
                        .font(.system(size: 20.0)).bold()
                        .foregroundColor(.gray)
                        .padding(.bottom,5)
                        .frame(maxWidth: .infinity, alignment: .leading)   // << here !!

                                  
                    RatingRow(movie:$movie)
                        .padding(.bottom,5)
                        .frame(maxWidth: .infinity, alignment: .leading)   // << here !!

                    
                    HStack {
                        let reviews = RatingDecode(movie: movie)
                        let imdb = reviews.getIMDB()
                        let rotten = reviews.getRottenTomatoes()
                        let meta = reviews.getMetaCritic()
                                            
                        
                        rotten.padding(.trailing, 10)
                        imdb.padding(.trailing, 10)
                        meta
                
                    }.frame(height: 50)
                    
                    
                    Text(m.plot())
                        .font(.system(size: 20.0))
                        .padding(.bottom,5)
                        .frame(height: 155, alignment: .topLeading)
                    
                    GenreRow(movie: $movie)
                    
                }.frame(width: (UIScreen.main.bounds.width-350))
            }
        }
        else {
            
            let reviews = RatingDecode(movie: movie)
            let imdb = reviews.getIMDB()
            let rotten = reviews.getRottenTomatoes()
            let meta = reviews.getMetaCrticRow()
            
            ZStack (alignment: .bottomLeading){
                WebImage(url: URL(string: m.background()))
                        .resizable()
                        .placeholder(Image("background"))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: 400)
                        .clipped() // Equal to clipsToBounds = true
                        .blur(radius:  6)

                VStack(alignment: .center) {
                    
                    Spacer()
                    
                    HStack {
                        WebImage(url: m.posterURL())
                            .resizable()
                            .renderingMode(.original)
                            .placeholder(Image("no_image"))
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                            .frame(width: 190, height: 265)
                        
                        
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text(m.title()).font(.system(size: 35)).bold().foregroundColor(.white).shadow(radius: 5)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)

                                BookmarkView(movie: $movie)
                            }
                            
                            Text(m.subString()).font(.system(size: 15)).bold().foregroundColor(.white).shadow(radius: 5)
                                .padding(.bottom, 1)

                            RatingRow(movie: $movie).padding(.bottom, 1)
                            
                            Text(m.plot()).font(.system(size: 15)).bold().foregroundColor(.white).shadow(radius: 5)
                                .padding(.bottom, 1)
                            
                            HStack {
                                imdb
                                meta
                                rotten
                            }
                            GenreRow(movie: $movie)

                        }
                        .frame(width: 580)
                        
                    }
                    
                    Spacer()
                    
                }.frame(width: UIScreen.main.bounds.width)


                
            }
            .frame(width: width, height: 400, alignment: .center)
            
        }
    
    }
}

struct MovieView: View {
    @EnvironmentObject var user: UserData

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    @State var movie: Movie
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false

    @State private var addedToCartAlert = false
    @State var qty = 0


    let height = (UIScreen.main.bounds.height)

    var body: some View {
        GeometryReader {geometry in
                ScrollView(.vertical, showsIndicators: false) {
                  if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                      iPhonePortraitMovieView(movie: $movie)
                      GenreRow(movie: $movie)
                          .padding(.bottom, 5)
                      DropDownMovie(movie: $movie)
                      CastRow(movie: $movie)

                  }
                  else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                      
                      iPhoneLandscapeMovieView(movie: $movie)
                      GenreRow(movie: $movie)
                          .padding(.bottom, 5)

                      DropDownMovie(movie: $movie)
                      CastRow(movie: $movie)

                  }
                  else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                      
                      iPadMovieView(movie: $movie)
                      DropDownMovie(movie: $movie)
                      CastRow(movie: $movie)

                  }
                  
              }
                
            ZStack{

                Button(action: {
                    print("Add button pressed...")
                    self.addCartData(movieId: movie.id, qty: 1)
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

               }.offset( x:(geometry.size.width/2)-100, y: geometry.size.height-70)
            }
            .onAppear(perform: {
                self.getMovieData()
               self.getCartQtyData()
           })

        }
        .toast(isPresenting: $addedToCartAlert){
            AlertToast(type: .complete(Color.green), title: "Added To Cart")}
        
    
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
                   
                ZStack {
                    Image(systemName: "cart").imageScale(.large)
                    
                    if(self.qty > 0) {
                        Text("\(self.qty)")
                            .foregroundColor(Color.black)
                            .background(Capsule().fill(Color.orange).frame(width:30, height:20))
                            .offset(x:20, y:-10)
                    }

                }
             }

           }
         }
       }

    }
    
    func addCartData(movieId: String, qty: Int) {
        API(user: user).addCart(movieId: movieId, qty: qty){ (result) in
            switch result {
            case .success( _ ):
                DispatchQueue.main.async {
                    addedToCartAlert = true
                    self.getCartQtyData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func getMovieData() {
        API(user: user).getMovie(id: movie.id) { (result) in
            switch result {
            case .success(let movie):
                DispatchQueue.main.async {
                    self.movie = movie
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getCartQtyData() {
        API(user: user).getCartQty(){ (result) in
            switch result {
            case .success(let qty):
                DispatchQueue.main.async {
                    self.qty = qty
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

