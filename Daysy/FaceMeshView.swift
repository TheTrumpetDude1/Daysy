//
//  FaceMeshView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 6/27/24.
//
/*
import SwiftUI
import UIKit
import SceneKit
import ARKit
import Pow

enum ExpressionType: Equatable {
    case positive(String)
    case negative(String)
    case undetermined
    
    static func ==(lhs: ExpressionType, rhs: ExpressionType) -> Bool {
        switch (lhs, rhs) {
        case (.positive(let leftExpression), .positive(let rightExpression)):
            return leftExpression == rightExpression
        case (.negative(let leftExpression), .negative(let rightExpression)):
            return leftExpression == rightExpression
        case (.undetermined, .undetermined):
            return true
        default:
            return false
        }
    }
}

struct FaceMeshView: View { //main welcome page
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentation
    
    @State var beginSetup = false
    
    @State var showTitle = false
    @State var showTips = false
    @State var showStarted = false
    
    let currCommunicationBoard = loadCommunicationBoard()
    
    var body: some View {
        if !beginSetup {
            NavigationView {
                VStack {
                    if horizontalSizeClass != .compact {
                        Spacer()
                    }
                    VStack {
                        Text("\(Image(systemName: "face.dashed"))")
                            .font(.system(size: horizontalSizeClass == .compact ? 85 : 115, weight: .bold, design: .rounded))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.cyan)
                        if showTitle {
                            VStack {
                                Text("Welcome to")
                                    .lineLimit(1)
                                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                                Text("Facial Decisions")
                                    .lineLimit(1)
                                    .font(.system(size: horizontalSizeClass == .compact ? 35 : 55, weight: .bold, design: .rounded))
                                Text("(Beta)")
                                    .lineLimit(1)
                                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .medium, design: .rounded))
                                    .foregroundStyle(.cyan.opacity(0.75))
                            }
                        }
                    }
                    Spacer()
                    if showTips {
                        VStack(alignment: .leading) {
                            HStack {
                                ZStack {
                                    Color.clear.frame(width: 40, height: 40)
                                        .padding(.trailing)
                                    Text("\(Image(systemName: "lightbulb.fill"))")
                                        .font(.system(size: 40, weight: .medium, design: .rounded))
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.cyan)
                                }
                                VStack(alignment: .leading) {
                                    Text("Find Good Lighting")
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 40, weight: .bold, design: .rounded))
                                    Text("Daysy uses your camera to analyze your face, so make sure you are well lit!")
                                        .font(.system(size: horizontalSizeClass == .compact ? 14 : 25, weight: .medium, design: .rounded))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .opacity(0.75)
                                }
                            }
                            .padding()
                            .padding([.leading, .trailing], horizontalSizeClass == .compact ? 0 : 15)
                            HStack {
                                ZStack {
                                    Color.clear.frame(width: 40, height: 40)
                                        .padding(.trailing)
                                    Text("\(Image(systemName: "eyes"))")
                                        .font(.system(size: 40, weight: .medium, design: .rounded))
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.cyan)
                                }
                                VStack(alignment: .leading) {
                                    Text("Select an Icon")
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 40, weight: .bold, design: .rounded))
                                    Text("Your face is your pointer! Point your nose at the icon you'd like to select.")
                                        .font(.system(size: horizontalSizeClass == .compact ? 14 : 25, weight: .medium, design: .rounded))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .opacity(0.75)
                                }
                            }
                            .padding()
                            .padding([.leading, .trailing], horizontalSizeClass == .compact ? 0 : 15)
                            HStack {
                                ZStack {
                                    Color.clear.frame(width: 40, height: 40)
                                        .padding(.trailing)
                                    Text("\(Image(systemName: "face.smiling"))")
                                        .font(.system(size: 40, weight: .medium, design: .rounded))
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.cyan)
                                }
                                VStack(alignment: .leading) {
                                    Text("Say Cheese!")
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 40, weight: .bold, design: .rounded))
                                    Text("Once you have your icon selected, you can smile to confirm your choice, or frown to remove it.")
                                        .font(.system(size: horizontalSizeClass == .compact ? 14 : 25, weight: .medium, design: .rounded))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .opacity(0.75)
                                }
                            }
                            .padding()
                            .padding([.leading, .trailing], horizontalSizeClass == .compact ? 0 : 10)
                        }
                    }
                    
                    Spacer()
                    
                    if showStarted {
                        HStack {
                            Button(action: {
                                self.presentation.wrappedValue.dismiss()
                            }) {
                                Text("\(Image(systemName: "arrow.backward"))")
                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.cyan)
                                    .padding(horizontalSizeClass == .compact ? 20 : 30)
                                    .background(.cyan.opacity(0.2))
                                    .cornerRadius(horizontalSizeClass == .compact ? 15 : 30)
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                withAnimation(.snappy) {
                                    beginSetup.toggle()
                                }
                            }) {
                                Text("Get Started")
                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color(.systemBackground))
                                    .padding(horizontalSizeClass == .compact ? 20 : 30)
                                    .padding([.leading, .trailing])
                                    .background(.cyan)
                                    .cornerRadius(horizontalSizeClass == .compact ? 15 : 30)
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding([.top, .bottom])
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarHidden(true)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                    withAnimation(.snappy) {
                        showTitle = true
                    }
                    Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                        withAnimation(.snappy) {
                            showTips = true
                        }
                        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                            withAnimation(.snappy) {
                                showStarted = true
                            }
                        }
                    }
                }
            }
        } else {
            ZStack {
                NavigationView {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            if horizontalSizeClass != .compact {
                                Spacer()
                            }
                            Text("Select a Folder")
                                .lineLimit(1)
                                .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                                .padding()
                            
                            Spacer()
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                                ForEach(0..<currCommunicationBoard.count, id: \.self) { index in
                                    if currCommunicationBoard[index].count > 1 {
                                        NavigationLink(destination: DecisionsView(currFolder: currCommunicationBoard[index])) {
                                            FolderPreviewView(currCommunicationBoard: currCommunicationBoard, index: index)
                                                .frame(width: horizontalSizeClass == .compact ? 100 : 150, height: horizontalSizeClass == .compact ? 100 : 150)
                                                .padding(.bottom)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarHidden(true)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.snappy) {
                                beginSetup.toggle()
                            }
                        }) {
                            Text("\(Image(systemName: "arrow.backward"))")
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(.systemBackground))
                                .padding(horizontalSizeClass == .compact ? 20 : 30)
                                .background(.cyan)
                                .cornerRadius(horizontalSizeClass == .compact ? 15 : 30)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground), Color.clear]), startPoint: .bottom, endPoint: .top)
                            .ignoresSafeArea()
                    )
                }
            }
            .transition(.movingParts.move(angle: .degrees(270)).combined(with: .opacity))
        }
    }
}

struct DecisionsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentation
    
    @State var currFolder: [String] = []
    
    @State var checkedCount = 0
    @State var removedCount = 0
    @State var analysis: String = " "
    @State var expressionType: ExpressionType = .undetermined
    @State private var elapsedTime: TimeInterval = 0
    let maxTime: TimeInterval = 1.5
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
    @State private var resetSignal = UUID()
    @State var images: [String] = []
    @State var eyePosition: simd_float3 = simd_float3(0, 0, 0)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BridgeView(analysis: $analysis, expressionType: $expressionType, eyePosition: $eyePosition)
                    .ignoresSafeArea()
                    .opacity(0.75)
                    .blur(radius: 15)
                VStack {
                    ZStack {
                        HStack {
                            Rectangle()
                                .frame(width: geometry.size.width * removedRatio, height: 15)
                                .foregroundStyle(.red)
                                .opacity(expressionColor == .green ? 1 - clampedProgress : 1)
                            Rectangle()
                                .frame(width: geometry.size.width * checkedRatio, height: 15)
                                .foregroundStyle(.green)
                                .opacity(expressionColor == .red ? 1 - clampedProgress : 1)
                        }
                        .blur(radius: 7.5)
                        HStack {
                            Text("\(Image(systemName: "xmark")) Removed: \(removedCount)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .foregroundStyle(.red)
                                .changeEffect(
                                    .spray(origin: UnitPoint(x: 0.5, y: 1.0)) {
                                        Image(systemName: "xmark")
                                            .foregroundStyle(.red)
                                    }, value: removedCount)
                                .changeEffect(.jump(height: 25), value: removedCount)
                                .shadow(radius: 10.0)
                                .padding(.leading)
                                .opacity(expressionColor == .green ? 1 - clampedProgress : 1)
                            Spacer()
                            Text("\(Image(systemName: "checkmark")) Checked: \(checkedCount)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .foregroundStyle(.green)
                                .changeEffect(
                                    .spray(origin: UnitPoint(x: 0.5, y: 1.0)) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.green)
                                    }, value: checkedCount)
                                .changeEffect(.jump(height: 25), value: checkedCount)
                                .shadow(radius: 10.0)
                                .padding(.trailing)
                                .opacity(expressionColor == .red ? 1 - clampedProgress : 1)
                        }
                        .shadow(radius: 5.0)
                    }
                    Spacer()
                    VStack {
                        //                        Text("\(eyePosition.x), \(eyePosition.y) : \(quadrant)")
                        //                            .font(.headline)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 0) {
                            ForEach(0..<images.count, id: \.self) { index in
                                Button(action: {
//                                    withAnimation(.snappy) {
//                                        if expressionColor == .green {
//                                            checkedCount += 1
//                                        } else if expressionColor == .red {
//                                            removedCount += 1
//                                        }
//                                        images = Array(currFolder.dropFirst().shuffled().prefix(4))
//                                    }
//                                    self.restartTimer()
                                }) {
                                    Image(images[index])
                                        .resizable()
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .scaledToFit()
                                        .shadow(radius: 10.0)
                                        .opacity(quadrant-1 == index ? 1 : (expressionColor == .primary ? 0.75 : 1-(elapsedTime/maxTime)))
                                        .overlay(
                                            ZStack {
                                                Image(systemName: expressionColor == .red ? "xmark" : "checkmark")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundStyle(expressionColor)
                                                    .padding()
                                                    .padding()
                                                    .opacity(expressionColor == .primary || quadrant-1 != index ? 0 : (elapsedTime/maxTime)/1.5)
                                                expressionColor
                                                    .opacity(expressionColor == .primary || quadrant-1 != index ?  0 : (elapsedTime/maxTime)/2)
                                            }
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        )
                                        .scaleEffect(expressionColor != .primary && quadrant-1 == index ? (1.0 + (elapsedTime/maxTime)/2) : (quadrant-1 == index ? 1.0 : 0.75))
                                }
                            }
                        }
                    }
                    Spacer()
                    /*
                    Button(action: {
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
                     */
                }
                .onChange(of: quadrant, perform: { _ in
                    self.restartTimer()
                })
            }
            var quadrant: Int {
                if (((geometry.size.width * CGFloat(-eyePosition.x)) * 1.5) + geometry.size.width/2) < geometry.size.width/2 {
                    if ((geometry.size.height * CGFloat(eyePosition.y) + geometry.size.height/2.5) * 2) < geometry.size.height/2 {
                        return 1
                    } else {
                        return 3
                    }
                } else {
                    if ((geometry.size.height * CGFloat(eyePosition.y) + geometry.size.height/2.5) * 2) < geometry.size.height/2 {
                        return 2
                    } else {
                        return 4
                    }
                }
            }
        }
        .animation(.snappy, value: true)
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            images = Array(currFolder.dropFirst().shuffled().prefix(4))
        }
        .onReceive(timer) { _ in
            if self.elapsedTime < maxTime {
                self.elapsedTime += 0.01
            } else if expressionColor != .primary {
                withAnimation(.snappy) {
                    if expressionColor == .green {
                        checkedCount += 1
                    } else if expressionColor == .red {
                        removedCount += 1
                    }
                    images = Array(currFolder.dropFirst().shuffled().prefix(4))
                }
                self.restartTimer()
            }
        }
        .onChange(of: expressionColor, perform: { _ in
            self.restartTimer()
        })
    }
    private func resetTimer() {
        self.elapsedTime = 0
        self.resetSignal = UUID()
    }
    
    private func restartTimer() {
        self.timer.upstream.connect().cancel()
        self.timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
        self.elapsedTime = 0
    }
    private var clampedProgress: Double {
        let progress = elapsedTime / maxTime
        if expressionType == .undetermined {
            return 0
        }
        return min(max(progress, 0), 1)
    }
    private var removedRatio: Double {
        if removedCount + checkedCount == 0 {
            return 0.5
        } else {
            return Double(removedCount) / Double(removedCount + checkedCount)
        }
    }
    private var checkedRatio: Double {
        if removedCount + checkedCount == 0 {
            return 0.5
        } else {
            return Double(checkedCount) / Double(removedCount + checkedCount)
        }
    }
    private var expressionColor: Color {
        switch expressionType {
        case .positive( _):
            return .green
        case .negative( _):
            return .red
        case .undetermined:
            return .primary
        }
    }
}

struct BridgeView: UIViewControllerRepresentable {
    @Binding var analysis: String
    @Binding var expressionType: ExpressionType
    @Binding var eyePosition: simd_float3
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        let storyBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil);
        let viewCtl = storyBoard.instantiateViewController(withIdentifier: "main") as! ViewController;
        
        viewCtl.reportChange = {
            // currSessionLog.append("reportChange")
            analysis = viewCtl.analysis
            expressionType = viewCtl.expressionType
            eyePosition = viewCtl.eyePosition
        }
        return viewCtl
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var faceLabel: UILabel!
    @IBOutlet weak var labelView: UIView!
    var analysis = " "
    var expressionType: ExpressionType = .undetermined
    var eyePosition: simd_float3 = simd_float3(0, 0, 0)
    var reportChange: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelView.layer.cornerRadius = 10
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        guard ARFaceTrackingConfiguration.isSupported else {
            return
        }
        
        // Disable UIKit label in Main.storyboard
        labelView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
            
            switch expressionType {
            case .positive( _):
                withAnimation(.snappy) { faceGeometry.firstMaterial?.diffuse.contents = UIColor.green }
            case .negative( _):
                withAnimation(.snappy) { faceGeometry.firstMaterial?.diffuse.contents = UIColor.red }
            case .undetermined:
                withAnimation(.snappy) { faceGeometry.firstMaterial?.diffuse.contents = UIColor.white }
            }
            
            DispatchQueue.main.async {
                self.reportChange()
            }
        }
    }
    
    func expression(anchor: ARFaceAnchor) {
        let blendShapes = anchor.blendShapes
        
        let smileLeft = blendShapes[.mouthSmileLeft]
        let smileRight = blendShapes[.mouthSmileRight]
        let cheekPuff = blendShapes[.cheekPuff]
        let tongue = blendShapes[.tongueOut]
        let browInnerUp = blendShapes[.browInnerUp]
        let browOuterUpLeft = blendShapes[.browOuterUpLeft]
        let browOuterUpRight = blendShapes[.browOuterUpRight]
        let eyeBlinkLeft = blendShapes[.eyeBlinkLeft]
        let eyeBlinkRight = blendShapes[.eyeBlinkRight]
        let jawOpen = blendShapes[.jawOpen]
        let mouthFunnel = blendShapes[.mouthFunnel]
        let mouthPucker = blendShapes[.mouthPucker]
        let mouthLeft = blendShapes[.mouthLeft]
        let mouthRight = blendShapes[.mouthRight]
        let noseSneerLeft = blendShapes[.noseSneerLeft]
        let noseSneerRight = blendShapes[.noseSneerRight]
        let eyeLookDownLeft = blendShapes[.eyeLookDownLeft]
        let eyeLookInLeft = blendShapes[.eyeLookInLeft]
        let eyeLookOutLeft = blendShapes[.eyeLookOutLeft]
        let eyeLookUpLeft = blendShapes[.eyeLookUpLeft]
        let eyeSquintLeft = blendShapes[.eyeSquintLeft]
        let eyeWideLeft = blendShapes[.eyeWideLeft]
        let eyeLookDownRight = blendShapes[.eyeLookDownRight]
        let eyeLookInRight = blendShapes[.eyeLookInRight]
        let eyeLookOutRight = blendShapes[.eyeLookOutRight]
        let eyeLookUpRight = blendShapes[.eyeLookUpRight]
        let eyeSquintRight = blendShapes[.eyeSquintRight]
        let eyeWideRight = blendShapes[.eyeWideRight]
        let jawForward = blendShapes[.jawForward]
        let jawLeft = blendShapes[.jawLeft]
        let jawRight = blendShapes[.jawRight]
        let mouthClose = blendShapes[.mouthClose]
        let mouthFrownLeft = blendShapes[.mouthFrownLeft]
        let mouthFrownRight = blendShapes[.mouthFrownRight]
        let mouthDimpleLeft = blendShapes[.mouthDimpleLeft]
        let mouthDimpleRight = blendShapes[.mouthDimpleRight]
        let mouthStretchLeft = blendShapes[.mouthStretchLeft]
        let mouthStretchRight = blendShapes[.mouthStretchRight]
        let mouthRollLower = blendShapes[.mouthRollLower]
        let mouthRollUpper = blendShapes[.mouthRollUpper]
        let mouthShrugLower = blendShapes[.mouthShrugLower]
        let mouthShrugUpper = blendShapes[.mouthShrugUpper]
        let mouthPressLeft = blendShapes[.mouthPressLeft]
        let mouthPressRight = blendShapes[.mouthPressRight]
        let mouthLowerDownLeft = blendShapes[.mouthLowerDownLeft]
        let mouthLowerDownRight = blendShapes[.mouthLowerDownRight]
        let mouthUpperUpLeft = blendShapes[.mouthUpperUpLeft]
        let mouthUpperUpRight = blendShapes[.mouthUpperUpRight]
        let browDownLeft = blendShapes[.browDownLeft]
        let browDownRight = blendShapes[.browDownRight]
        let cheekSquintLeft = blendShapes[.cheekSquintLeft]
        let cheekSquintRight = blendShapes[.cheekSquintRight]
        
        self.analysis = " "
        self.expressionType = .undetermined
        self.eyePosition = anchor.lookAtPoint
        
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.5 {
            self.analysis += "You are smiling. "
            self.expressionType = .positive("smile")
        }
        
        if cheekPuff?.decimalValue ?? 0.0 > 0.25 {
            self.analysis += "Your cheeks are puffed. "
            self.expressionType = .undetermined
        }
        
        if tongue?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Don't stick your tongue out! "
            self.expressionType = .undetermined
        }
        
        if (browOuterUpLeft?.decimalValue ?? 0.0 > 0.25) || (browOuterUpRight?.decimalValue ?? 0.0 > 0.25) || browInnerUp?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Your brows are raised. "
            self.expressionType = .undetermined
        }
        
        if jawOpen?.decimalValue ?? 0.0 > 0.25 {
            self.analysis += "Your jaw is open. "
            self.expressionType = .undetermined
        }
//        
        if mouthFunnel?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Your mouth is in a funnel shape. "
        self.expressionType = .undetermined
        }
        
        if mouthPucker?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Your lips are puckered. "
            self.expressionType = .undetermined
        }
        
        if mouthLeft?.decimalValue ?? 0.0 > 0.15 {
            self.analysis += "Your mouth is moved to the left. "
            self.expressionType = .undetermined
        }
        
        if mouthRight?.decimalValue ?? 0.0 > 0.15 {
            self.analysis += "Your mouth is moved to the right. "
            self.expressionType = .undetermined
        }
        
        if (noseSneerLeft?.decimalValue ?? 0.0 > 0.15) || (noseSneerRight?.decimalValue ?? 0.0 > 0.15) {
            self.analysis += "You are sneering. "
            if case .positive = self.expressionType {
                //for now do nothing because we don't want to override smile
            } else {
                self.expressionType = .negative("sneer")
            }
        }
        
        if (eyeBlinkLeft?.decimalValue ?? 0.0 > 0.9) || (eyeBlinkRight?.decimalValue ?? 0.0 > 0.9) {
            self.analysis += "You are blinking. "
            self.expressionType = .undetermined
        }
        
        if (eyeLookDownLeft?.decimalValue ?? 0.0 > 0.5) || (eyeLookDownRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are looking down. "
            self.expressionType = .undetermined
        }
        
        if (eyeLookInLeft?.decimalValue ?? 0.0 > 0.5) || (eyeLookInRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are looking inward. "
            self.expressionType = .undetermined
        }
        
        if (eyeLookOutLeft?.decimalValue ?? 0.0 > 0.5) || (eyeLookOutRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are looking outward. "
            self.expressionType = .undetermined
        }
        
        if (eyeLookUpLeft?.decimalValue ?? 0.0 > 0.5) || (eyeLookUpRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are looking up. "
            self.expressionType = .undetermined
        }
        
        if (eyeSquintLeft?.decimalValue ?? 0.0 > 0.5) || (eyeSquintRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are squinting. "
            self.expressionType = .undetermined
        }
        
        if (eyeWideLeft?.decimalValue ?? 0.0 > 0.9) || (eyeWideRight?.decimalValue ?? 0.0 > 0.9) {
            self.analysis += "Your eyes are wide open. "
            self.expressionType = .undetermined
        }
        
        if jawForward?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Your jaw is moved forward. "
            self.expressionType = .undetermined
        }
        
        if (jawLeft?.decimalValue ?? 0.0 > 0.9) || (jawRight?.decimalValue ?? 0.0 > 0.9) {
            self.analysis += "Your jaw is moving left or right. "
            self.expressionType = .undetermined
        }
        
        if mouthClose?.decimalValue ?? 0.0 > 0.15 {
            self.analysis += "Your mouth is closed. "
            self.expressionType = .undetermined
        }
        
        if (mouthFrownLeft?.decimalValue ?? 0.0 > 0.25) || (mouthFrownRight?.decimalValue ?? 0.0 > 0.25) {
            self.analysis += "Your mouth is frowning. "
            self.expressionType = .negative("frown")
        }
        
        if (mouthDimpleLeft?.decimalValue ?? 0.0 > 0.5) || (mouthDimpleRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You have dimples on your mouth. "
            self.expressionType = .undetermined
        }
        
        if (mouthStretchLeft?.decimalValue ?? 0.0 > 0.5) || (mouthStretchRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your mouth is stretched. "
            self.expressionType = .undetermined
        }
        
        if (mouthRollLower?.decimalValue ?? 0.0 > 0.5) || (mouthRollUpper?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your mouth is rolling. "
            self.expressionType = .undetermined
        }
        
        if (mouthShrugLower?.decimalValue ?? 0.0 > 0.5) || (mouthShrugUpper?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are shrugging your mouth. "
            if case .positive = self.expressionType {
                //for now do nothing because we don't want to override smile
            } else {
                self.expressionType = .negative("shrug")
            }
        }
        
        if (mouthPressLeft?.decimalValue ?? 0.0 > 0.5) || (mouthPressRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are pressing your mouth to the left or right. "
        }
        
        if (mouthLowerDownLeft?.decimalValue ?? 0.0 > 0.5) || (mouthLowerDownRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your lower mouth is moving down. "
        }
        
        if (mouthUpperUpLeft?.decimalValue ?? 0.0 > 0.5) || (mouthUpperUpRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your upper mouth is moving up. "
        }
        
        if (browDownLeft?.decimalValue ?? 0.0 > 0.75) || (browDownRight?.decimalValue ?? 0.0 > 0.75) {
            self.analysis += "Your brows are moving down. "
            self.expressionType = .negative("brows down")
        }
        
        if (cheekSquintLeft?.decimalValue ?? 0.0 > 0.5) || (cheekSquintRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your cheeks are squinting. "
        }
    }
}
*/
