//
//  HiddenIconsView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 7/3/24.
//

import SwiftUI
import Pow

struct HiddenIconsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentation
    @State var customIconPreviews: [String : UIImage] = [:]
    @State var hiddenIcons = loadHiddenIcons()
    @State var selectedIndex = -1
    var body: some View {
        ZStack {
            ScrollView {
                HStack(alignment: .top) {
                    VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                        Text("\(Image(systemName: "eye.slash")) Hidden Icons")
                            .lineLimit(1)
                        //.minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            .padding(.top)
                            .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                            .symbolRenderingMode(.hierarchical)
                        if hiddenIcons.count > 0 {
                            Text("You have \(hiddenIcons.count) Hidden Icon\(hiddenIcons.count == 1 ? "" : "s"). When you hide an icon from your Communication Board, you can view and/or restore it from here.")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(horizontalSizeClass == .compact ? .leading : .center)
                                .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                    if horizontalSizeClass == .compact {
                        Spacer()
                    }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                    ForEach(0..<hiddenIcons.count, id: \.self) { index in
                        Button(action: {
                            if selectedIndex == index {
                                withAnimation(.snappy) {
                                    hiddenIcons.remove(at: index)
                                    saveHiddenIcons(hiddenIcons)
                                    selectedIndex = -1
                                }
                            } else {
                                withAnimation(.snappy) {
                                    selectedIndex = index
                                }
                            }
                        }) {
                            if UIImage(named: hiddenIcons[index]) == nil {
                                Image(uiImage: customIconPreviews[hiddenIcons[index]] ?? UIImage(systemName: "square.fill")!)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.black, lineWidth: 3)
                                    )
                                    .opacity(selectedIndex == index ? 0.25 : 1)
                            } else {
                                Image(hiddenIcons[index])
                                    .resizable()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .opacity(selectedIndex == index ? 0.25 : 1)
                                    .overlay(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.black, lineWidth: 3)
                                                .opacity(selectedIndex == index ? 0.25 : 1)
                                            VStack {
                                                Image(systemName: "checkmark.gobackward")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .symbolRenderingMode(.hierarchical)
                                                    .foregroundStyle(.purple)
                                                    .padding()
                                                    .opacity(selectedIndex == index ? 0.85 : 0)
                                                Text("Restore")
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.1)
                                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.purple)
                                                    .opacity(selectedIndex == index ? 0.85 : 0)
                                            }
                                        }
                                    )
                                    .scaledToFit()
                            }
                        }
                    }
                }
                .padding()
                .padding(.bottom, 150)
                Spacer()
                if hiddenIcons.count == 0 {
                    Text("You don't have any Hidden Icons yet. Once you hide an icon from your Communication Board, you can view and/or restore it from here.")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.gray)
                        .padding()
                        .padding()
                    Spacer()
                }
            }
            .onTapGesture {
                withAnimation(.snappy) {
                    selectedIndex = -1
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        hiddenIcons = loadHiddenIcons()
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("\(Image(systemName: "arrow.backward")) ")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .padding([.top, .bottom, .leading], horizontalSizeClass == .compact ? 5 : 10)
                                .foregroundStyle(.gray)
                            Text("Back")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                .foregroundStyle(.primary)
                            
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground),  Color.clear]), startPoint: .bottom, endPoint: .top)
                        .ignoresSafeArea()
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .onAppear {
            Task {
                do {
                    customIconPreviews = await getCustomIconPreviews()
                }
            }
        }
    }
}

#Preview {
    HiddenIconsView()
}
