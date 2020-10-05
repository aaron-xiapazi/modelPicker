//
//  ContentView.swift
//  Reality
//
//  Created by aaron on 2020/10/3.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    @State private var isPlacementEnable = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    
    
    var models : [Model] = {
        let fileManager = FileManager.default
        
        guard let path = Bundle.main.resourcePath,let files = try? fileManager.contentsOfDirectory(atPath: path)else{
            return []
        }
        
        var availableModels : [Model] = []
        for filename in files where
            filename.hasSuffix("usdz"){
            let modelname = filename.replacingOccurrences(of: ".usdz", with: "")
            
            let model = Model(modelName: modelname)
            availableModels.append(model)
        }
        return availableModels
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(confirmedModel: self.$modelConfirmedForPlacement)
            
            if self.isPlacementEnable{
                PlacementButtonView(isPlacementEnable: self.$isPlacementEnable, selectedModel: self.$selectedModel, modelConfirmForPlacement: self.$modelConfirmedForPlacement)
            }else{
                ModelPickerView(isPlacementEnable: self.$isPlacementEnable, selectedModel: self.$selectedModel, models: self.models)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmForPlacement: Model?
    
    func makeUIView(context: Context) -> ARView {
        
//        let arView = ARView(frame: .zero)
        
        let arView = CustomARView(frame: .zero)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model =
            self.modelConfirmForPlacement{
            
            if let modelEntity  = model.modelEntity{
                print("DEBUG adding model to scene = \(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            }else{
                print("DEBUG unable to load  model to scene for \(model.modelName)")
            }
            
            
            DispatchQueue.main.async {
                self.modelConfirmForPlacement = nil
            }
        }
    }
    
}

class CustomARView: ARView{
    let focusSquare = FESquare()
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        focusSquare.viewDelegate = self
        focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true)
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupARView(){
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
            config.sceneReconstruction = .mesh
        }
        self.session.run(config)
    }
}

extension CustomARView: FEDelegate{
    func toTrackingState() {
        print("tracking")
    }
    
    func toInitializingState() {
        print("iniitializing")
    }
}

struct ModelPickerView: View {
    @Binding var isPlacementEnable: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View{
        ScrollView (.horizontal){
            HStack(spacing: 30){

                ForEach(0 ..< self.models.count){
                    index in
                    Button(action: {
                        print("DEBUG : selected model with name : \(self.models[index].modelName)")
                        self.selectedModel = self.models[index]
                        
                        self.isPlacementEnable = true
                    }){
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1,contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonView: View {
    @Binding var isPlacementEnable: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmForPlacement: Model?
    var body: some View{
        HStack{
            // cancel Button
            Button(action: {
                print("DEBUG : Cancel model placement cancel ")
                self.resetPlacementParameters()
            }){
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            //Confirm Button
            Button(action: {
                print("DEBUG : Cancel model placement confirmed")
                self.modelConfirmForPlacement = self.selectedModel
                self.resetPlacementParameters()
            }){
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnable = false
        self.selectedModel = nil
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
