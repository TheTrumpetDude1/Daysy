//
//  CanvasView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 5/24/24.
//
import SwiftUI

struct Line {
    var points: [CGPoint]
    var color: Color
}

struct CanvasView: View {
    
    var onDismiss: () -> Void
    @State private var lines: [Line] = []
    @State private var selectedColor: Color = .primary
    
    var body: some View {
        VStack {
            Canvas {ctx, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    
                    ctx.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.color == Color(.systemBackground) ? 30 : 5, lineCap: .round, lineJoin: .round))
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        let position = value.location
                        
                        if value.translation == .zero {
                            lines.append(Line(points: [position], color: selectedColor))
                        } else {
                            guard let lastIdx = lines.indices.last else {
                                return
                            }
                            
                            lines[lastIdx].points.append(position)
                        }
                    })
            )
            HStack {
                ForEach([Color.green, .orange, .blue, .red, .pink, .primary, Color.accentColor, Color(.systemBackground)], id: \.self) { color in
                    colorButton(color: color)
                }
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }
    
    @ViewBuilder
    func colorButton(color: Color) -> some View {
        Button {
            selectedColor = color
        } label: {
            if color == Color(.systemBackground) {
                if color == selectedColor {
                    Image(systemName: "eraser.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.pink)
                } else {
                    Image(systemName: "eraser")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)
                }
            } else {
                if color == selectedColor {
                    Image(systemName: "pencil.tip.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(color)
                } else {
                    Image(systemName: "circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(color)
                        .mask {
                            Image(systemName: "pencil.tip")
                                .font(.largeTitle)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    func clearButton() -> some View {
        Button {
            lines = []
        } label: {
            Image(systemName: "pencil.tip.crop.circle.badge.minus")
                .font(.largeTitle)
                .foregroundStyle(.gray)
        }
    }
}
