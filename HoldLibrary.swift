//
//  HoldLibrary.swift
//  Routesetting
//
//  Created by Benny Kuttler on 12/23/22.
//

import Foundation
import UIKit

struct Hold {
    var image: UIImage
    var size: CGSize
    var rotation: CGFloat
}

class HoldLibrary: UIView {
    private var holds = [Hold]()
    
    required init?(coder: NSCoder) {
        // Call the superclass initializer
        super.init(coder: coder)
        
        // Decode the holds array
        if let holds = coder.decodeObject(forKey: "holds") as? [Hold] {
            self.holds = holds
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let fileManager = FileManager.default
        let baseDirectory = "Holds"
        
        func addHolds(inDirectory directory: String) {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: directory)
                for item in contents {
                    let fullPath = "\(directory)/\(item)"
                    var isDirectory = ObjCBool(true)
                    if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            addHolds(inDirectory: fullPath)
                        } else {
                            // Load the image and create a hold object
                            let image = UIImage(named: fullPath)!
                            let hold = Hold(image: image, size: .zero, rotation: 0)
                            holds.append(hold)
                        }
                    }
                }
            } catch {
                print("Error reading contents of directory: \(error)")
            }
        }
        
        // Load all the holds from the base directory
        addHolds(inDirectory: baseDirectory)
    }
    
    override func encode(with coder: NSCoder) {
        // Encode the holds array
        coder.encode(holds, forKey: "holds")
    }
}

/*    required init?(coder: NSCoder) {
        // Decode the holds array
        if let holds = coder.decodeObject(forKey: "holds") as? [Hold] {
            self.holds = holds
        }
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        // Encode the holds array
        coder.encode(holds, forKey: "holds")
    } */

