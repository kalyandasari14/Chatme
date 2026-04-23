//
//  SignInView.swift
//  Chatme
//
//  Created by kalyan on 4/7/26.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore

struct SignInView: View {
    @AppStorage("isSignedIn") private var isSignedIn = false
    @State private var errorMessage = ""
  
    
    var body: some View {
        if isSignedIn{
            ChatRoomListView()
        }else{
            VStack(spacing: 20){
                Text("Chat Me")
                    .font(.largeTitle)
                    .bold()
                
                Text("Real-time messaging")
                    .foregroundStyle(.secondary)
                
                if !errorMessage.isEmpty{
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                Button("Sign In With Google"){
                    signInWithGoogle()
                }.buttonStyle(.borderedProminent)
                
            }.padding()
                .onAppear{
                    checkIfSignedIn()
                }
        }
    }
    
    func checkIfSignedIn(){
        if Auth.auth().currentUser != nil{
            isSignedIn = true
        }
    }
    
    func signInWithGoogle(){
        print("========== SIGN IN BUTTON TAPPED ==========")
        // step 1: Get the UIViewController to present Google's sign-in Popup
        // SwiftUi doesnt have view Controllers,so we dig into Uikit to find one
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ No root view controller")
            DispatchQueue.main.async {
                errorMessage = "Unable to find window"
            }
            return
        }
        print("✅ Got root view controller")
        
        print("🔵 Step 2: Getting client ID")
        //step 2: we are getting firebase client id from googleservice - info.plist
        // this Id tells Google which project I'm signing into
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ No client ID found")
            DispatchQueue.main.async {
                errorMessage = "Firebase configuration error"
            }
            return
        }
        print("✅ Got client ID: \(clientID)")
        
        print("🔵 Step 3: Configuring Google Sign-In")
        //step 3 : we are authenicating firebase client id to match google id to match it in our google info- plist
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        print("✅ Configured")
        
        print("🔵 Step 4: Showing Google Sign-In popup")
        //step 4 : we are sharing instance with the result matching with the credential to see if both ids matches and result matches we will proceed or if its an error we will show it to the user
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [self] result, error in
            if let error = error {
                print("❌ Google error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Google sign-in failed: \(error.localizedDescription)"
                }
                return
            }
            print("✅ Google sign-in successful")
            
            //step 5: if the sign is succesful then we are getting tokens from google to validate the user and we will get the user data, so we can use it in the future
            
            print("🔵 Step 5: Extracting tokens")
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ No tokens")
                DispatchQueue.main.async {
                    self.errorMessage = "Unable to get authentication tokens"
                }
                return
            }
            print("✅ Got tokens")
            
            //step 6: we will match the tokens and create a firebase credential in the database
            
            print("🔵 Step 6: Creating Firebase credential")
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString)
            print("✅ Created credential")
            
            //step 7: we will succesfully sign in the firebase using fire base credential
            
            print("🔵 Step 7: Signing in to Firebase")
            Auth.auth().signIn(with: credential) { [self] authResult, error in
                if let error = error {
                    print("❌ Firebase error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.errorMessage = "Firebase sign-in failed: \(error.localizedDescription)"
                    }
                    return
                }
                
                if let user = authResult?.user {
                    print("✅ Email: \(user.email ?? "")")
                    print("✅ User ID: \(user.uid)")
                    print("✅ Name: \(user.displayName ?? "")")
                    
                    DispatchQueue.main.async {
                        self.isSignedIn = true
                    }
                }
            }
        }
    }
}

#Preview {
    SignInView()
}
