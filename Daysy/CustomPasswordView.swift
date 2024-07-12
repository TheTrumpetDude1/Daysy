//
//  CustomPasswordView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/19/23.
//

import SwiftUI

struct CustomPasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode
    var dismissSheet: (Bool) -> Void
    @State var fromSettings = false
    
    @State private var password = ""
    @State private var verifyPassword = ""
    @State private var showVerify = false
    @State private var mismatch = false
    @AppStorage("buttonsOn") private var buttonsOn: Bool = false

    var body: some View { //set and/or verify custom password if bioauth and password not set
        if buttonsOn {
            let customPassword = defaults.string(forKey: "customPassword")
            
            VStack {
                Spacer()
                if mismatch {
                    Text("Incorrect Password")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                        .padding()
                }
                Text("Enter Your Password")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .padding()
                
                SecureField("Password", text: $password)
                    .keyboardType(.numberPad)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .frame(width: 400)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray4))
                    )
                    .padding()
                    .padding(.bottom)
                
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                    ForEach(1...9, id: \.self) { number in
                        NumberButton(number: number, password: $password)
                            .foregroundStyle(.primary)
                            .padding()
                    }
                    Image(systemName: "checkmark")
                        .font(.title)
                    //.fontWeight(.semibold)
                        .foregroundStyle(password != "" ? .green : .clear)
                        .onTapGesture {
                            if password == customPassword {
                                buttonsOn.toggle()
                                dismissSheet(fromSettings ? buttonsOn : !buttonsOn)
                                mismatch = false
                                password = ""
                            } else {
                                mismatch = true
                                password = ""
                            }
                        }
                    NumberButton(number: 0, password: $password)
                        .foregroundStyle(.primary)
                        .padding()
                    Image(systemName: "delete.left")
                        .font(.title)
                    //.fontWeight(.semibold)
                        .foregroundStyle(.red)
                        .onTapGesture {
                            if !password.isEmpty {
                                password.removeLast()
                            }
                        }
                }
                .frame(width: 400)
                Spacer()
            }
        } else {
            if !showVerify {
                VStack {
                    Spacer()
                    if mismatch {
                        Text("Passwords Do Not Match")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                            .padding()
                    }
                    Text("Create A Password")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding()
                    
                    SecureField("Password", text: $password)
                        .keyboardType(.numberPad)
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .frame(width: 400)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray4))
                        )
                        .padding()
                        .padding(.bottom)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(1...9, id: \.self) { number in
                            NumberButton(number: number, password: $password)
                                .foregroundStyle(.primary)
                                .padding()
                        }
                        Image(systemName: "checkmark")
                            .font(.title)
                        //.fontWeight(.semibold)
                            .foregroundStyle(password != "" ? .green : .clear)
                            .onTapGesture {
                                showVerify = true
                            }
                        NumberButton(number: 0, password: $password)
                            .foregroundStyle(.primary)
                            .padding()
                        Image(systemName: "delete.left")
                            .font(.title)
                        //.fontWeight(.semibold)
                            .foregroundStyle(.red)
                            .onTapGesture {
                                if !password.isEmpty {
                                    password.removeLast()
                                }
                            }
                    }
                    .frame(width: 400)
                    Spacer()
                }
                .padding()
                .animation(.snappy, value: true)
            } else {
                VStack {
                    Spacer()
                    Text("Enter Your Password Again")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding()
                    
                    SecureField("Verify Password", text: $verifyPassword)
                        .keyboardType(.numberPad)
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .frame(width: 400)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray4))
                        )
                        .padding()
                        .padding(.bottom)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(1...9, id: \.self) { number in
                            NumberButton(number: number, password: $verifyPassword)
                                .foregroundStyle(.primary)
                                .padding()
                        }
                        Image(systemName: "checkmark")
                            .font(.title)
                        //.fontWeight(.semibold)
                            .foregroundStyle(.green)
                            .onTapGesture {
                                if password == verifyPassword {
                                    defaults.set(password, forKey: "customPassword")
                                    currSessionLog.append("Custom Password Set: \(password)")
                                    buttonsOn.toggle()
                                    dismissSheet(fromSettings ? buttonsOn : !buttonsOn)
                                    
                                } else {
                                    currSessionLog.append("Passwords do not match, resetting")
                                    mismatch = true
                                    password = ""
                                    verifyPassword = ""
                                    showVerify = false
                                }
                            }
                        NumberButton(number: 0, password: $verifyPassword)
                            .foregroundStyle(.primary)
                            .padding()
                        Image(systemName: "delete.left")
                            .font(.title)
                        //.fontWeight(.semibold)
                            .foregroundStyle(.red)
                            .onTapGesture {
                                if !verifyPassword.isEmpty {
                                    verifyPassword.removeLast()
                                }
                            }
                    }
                    .frame(width: 400)
                    Spacer()
                }
                .padding()
                .animation(.snappy, value: true)
            }
        }
    }
}

struct CheckPasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode
        var dismissSheet: () -> Void
    
    let customPassword = defaults.string(forKey: "customPassword")
    @State private var password = ""
    @State var mismatch = false

    var body: some View {
        VStack {
            Spacer()
            Text("Enter Your Password")
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .font(.system(size: 30,  weight: .bold, design: .rounded))
                .padding()
            
            SecureField("Password", text: $password)
                .keyboardType(.numberPad)
                .font(.system(size: 40,  weight: .semibold, design: .rounded))
                .frame(width: 400)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray4))
                )
                .padding()
                .padding(.bottom)
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(1...9, id: \.self) { number in
                    NumberButton(number: number, password: $password)
                        .foregroundStyle(.primary)
                        .padding()
                }
                Image(systemName: "checkmark")
                    .font(.title)
                    //.fontWeight(.semibold)
                    .foregroundStyle(password != "" ? .green : .clear)
                    .onTapGesture {
                        if password == customPassword {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                NumberButton(number: 0, password: $password)
                    .foregroundStyle(.primary)
                    .padding()
                Image(systemName: "delete.left")
                    .font(.title)
                    //.fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .onTapGesture {
                        if !password.isEmpty {
                            password.removeLast()
                        }
                    }
            }
            .frame(width: 400)
            Spacer()
        }
        .padding()
        .animation(.snappy, value: true)
    }
}

struct NumberButton: View {
    let number: Int
    @Binding var password: String

    var body: some View {
        Button(action: {
            password += "\(number)"
        }) {
            Text("\(number)")
                .font(.system(size: 30, design: .rounded))
                .fontWeight(.semibold)
                .frame(width: 80, height: 80)
                .background(Color(.systemGray4))
                .cornerRadius(40)
        }
    }
}
