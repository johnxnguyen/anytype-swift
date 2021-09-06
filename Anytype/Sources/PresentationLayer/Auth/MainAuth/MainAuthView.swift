import SwiftUI


struct MainAuthView: View {
    @ObservedObject var viewModel: MainAuthViewModel
    @State private var showLoginView: Bool = false
    
    var body: some View {
        ZStack {
            navigation
            Image.auth.background
                .resizable()
                .edgesIgnoringSafeArea(.all)
            contentView
                
            .errorToast(
                isShowing: $viewModel.isShowingError, errorText: viewModel.error
            )
        }
        .navigationBarHidden(true)
        .modifier(LogoOverlay())
        .onAppear {
            viewModel.viewLoaded()
        }
    }
    
    private var contentView: some View {
        VStack() {
            Spacer()
            bottomSheet
        }
    }
    
    private var bottomSheet: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                AnytypeText("Welcome to Anytype", style: .heading)
                    .padding(.bottom, 11)
                AnytypeText("OrganizeEverythingDescription", style: .uxCalloutRegular)
                    .lineSpacing(7)
            }.padding(20)
            
            HStack(spacing: 10) {
                StandardButton(text: "Sign up", style: .secondary) {
                    viewModel.singUp()
                }
                
                NavigationLink(
                    destination: viewModel.loginView()
                ) {
                    StandardButtonView(text: "Login", style: .primary)
                }
            }
            .padding([.leading, .trailing], 20)
            .padding(.bottom, 10)
        }
        .background(Color.background)
        .cornerRadius(16.0)
        .padding(20)
    }
    
    private var navigation: some View {
        NavigationLink(
            destination: viewModel.signUpFlow(),
            isActive: $viewModel.showSignUpFlow
        ) {
            EmptyView()
        }
    }
}


struct MainAuthView_Previews : PreviewProvider {
    static var previews: some View {
        MainAuthView(viewModel: MainAuthViewModel())
    }
}
