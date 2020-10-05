//
//  Model.swift
//  Reality
//
//  Created by aaron on 2020/10/3.
//

import UIKit
import RealityKit
import Combine

class Model{
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion:{
                loadCompletion in
                // handle error
                print("DEBUG Unable to load modelENtity for modelname : \(self.modelName)")
            },receiveValue: {
                modelEntity in
                // get out modelEntity
                self.modelEntity = modelEntity
                print("DEBUG : successfully loaded modelEnity for modelName :\(self.modelName)")
            })
        
    }
}
