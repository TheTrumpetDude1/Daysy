//
//  TimeLabelPickerView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 5/6/24.
//

import SwiftUI

enum PickerViewType {
    case time
    case label
}

struct TimeLabelPickerView: View {
    let viewType: PickerViewType
    var saveItem: (Any) -> Void
    var oldDate = Date()
    @Binding var oldLabel: String
    
    var body: some View {
        switch viewType {
        case .time:
            return AnyView(TimePickerView(
                saveTime:{ newTime in
                saveItem(newTime)
                }, currDate: oldDate, oldDate: oldDate))
        case .label:
            return AnyView(LabelPickerView(
                saveLabel: { newLabel in
                saveItem(newLabel)
                }, currLabel: oldLabel, oldLabel: oldLabel))
        }
    }
}

struct TimePickerView: View {
    var saveTime: (Date) -> Void
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var currDate = Date()
    var oldDate = Date()
    
    var body: some View {
        if horizontalSizeClass == .compact {
            Spacer()
            Button(action: {
                self.presentation.wrappedValue.dismiss()
            }) {
                Text("\(Image(systemName: "xmark.circle.fill"))")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.gray)
                    .symbolRenderingMode(.hierarchical)
            }
        }
        Spacer()
        DatePicker("", selection: $currDate, displayedComponents: .hourAndMinute)
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .frame(width: 400, height: 400)
            .scaleEffect(horizontalSizeClass == .compact ? 1.5 : 3)
        Spacer()
        Button(action: {
            if currDate != oldDate {
                saveTime(currDate)
            }
            
            self.presentation.wrappedValue.dismiss()
        }) {
            Image(systemName: currDate != oldDate ? "checkmark.square.fill" : "xmark.square.fill")
                .resizable()
                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                .foregroundStyle(currDate != oldDate ? .gray : .green)
                .symbolRenderingMode(.hierarchical)
                .padding()
        }
    }
}

struct LabelPickerView: View {
    var saveLabel: (String) -> Void
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @FocusState var isLabelFocused: Bool
    
    @State var currLabel = ""
    var oldLabel = ""
    @State private var suggestedWords: [String] = []
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                TextField("Your Label", text: $currLabel)
                    .focused($isLabelFocused)
                    .font(.system(size: horizontalSizeClass == .compact ? 35 : 65, weight: .semibold, design: .rounded))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray5))
                    )
                    .onChange(of: currLabel, perform: { _ in
                        suggestedWords = updateSuggestedWords(currLabel: currLabel)
                    })
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(suggestedWords.prefix(horizontalSizeClass == .compact ? 10 : 20), id: \.self) { word in
                        Button(action: {
                            let words = currLabel.split(separator: " ")
                            if var lastWord = words.last {
                                lastWord = Substring(word)
                                currLabel = words.dropLast().joined(separator: " ") + " " + lastWord
                            } else {
                                currLabel = word
                            }
                        }) {
                            Text(word)
                                .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .medium, design: .rounded))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray5))
                                )
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
                if suggestedWords.count == 0 {
                    Text("filler")
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .medium, design: .rounded))
                        .padding(2)
                        .foregroundStyle(.clear)
                }
            }
            Spacer()
            Button(action: {
                if currLabel.isEmpty || currLabel == oldLabel {
                    self.presentation.wrappedValue.dismiss()
                } else {
                    saveLabel(currLabel)
                    self.presentation.wrappedValue.dismiss()
                }
            }) {
                Image(systemName: currLabel.isEmpty || currLabel == oldLabel ? "xmark.square.fill" : "checkmark.square.fill")
                    .resizable()
                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                    .foregroundStyle(currLabel.isEmpty || currLabel == oldLabel ? .green : .gray)
                    .symbolRenderingMode(.hierarchical)
                    .padding()
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear{
            suggestedWords = updateSuggestedWords(currLabel: currLabel)
        }
        .padding()
    }
}

//#Preview {
//    TimeLabelPickerView(viewType: .label, saveItem: {newItem in})
//}
