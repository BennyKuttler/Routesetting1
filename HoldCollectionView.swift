//
//  HoldCollectionView.swift
//  Routesetting
//
//  Created by Benny Kuttler on 12/29/22.
//

import Foundation
import UIKit

class HoldSelectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    // Hold image that the user has selected from the hold view collection view
    var selectedHold: UIImage?
    // Image view that represents the climbing wall
    var wallImage: UIImageView?
    // Collection view that displays the available holds
    var holdView: UICollectionView?
    // Gesture recognizer for long press on a hold image
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    // Gesture recognizer for panning (dragging) a hold image
    let panGestureRecognizer = UIPanGestureRecognizer()
    // File manager to read the contents of the holds directory
    let fileManager = FileManager.default
    // Directory that contains the images of the climbing holds
    let holdDirectory = Bundle.main.path(forResource: "Holds", ofType: nil)
    // Array of file names for the hold images
    var holdFileNames: [String] = []
    // Array of UIImage objects for the hold images
    var holds: [UIImage] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the hold cell class for the hold view collection view
        collectionView.register(HoldCell.self, forCellWithReuseIdentifier: "HoldCell")

        // Add the long press and pan gesture recognizers to the hold view collection view
        for cell in holdView?.visibleCells ?? [] {
            cell.addGestureRecognizer(longPressGestureRecognizer)
            cell.addGestureRecognizer(panGestureRecognizer)
        }
        // Set the targets and actions for the gesture recognizers
        longPressGestureRecognizer.addTarget(self, action: #selector(handleLongPress(_:)))
        panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return holds.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HoldCell", for: indexPath) as! HoldCell
        let holdImage = UIImage(named: "Holds/hold\(indexPath.row)")
        cell.holdView.image = holdImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedHold = UIImage(named: "Holds/hold\(indexPath.row)")
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let wallImage = wallImage, let selectedHold = selectedHold else { return }
        
        let location = gesture.location(in: wallImage)
        let hold = UIImageView(image: selectedHold)
        hold.frame.size = CGSize(width: 50, height: 50)
        hold.center = location
        wallImage.addSubview(hold)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            // create a new hold image view and add it to the wall image view
            let holdImageView = UIImageView(image: selectedHold)
            holdImageView.center = gesture.location(in: wallImage)
            wallImage!.addSubview(holdView!)
        case .changed:
            // update the position of the hold image view as the user moves their finger
            let translation = gesture.translation(in: wallImage)
            holdView!.center = CGPoint(x: holdView!.center.x + translation.x, y: holdView!.center.y + translation.y)
            gesture.setTranslation(.zero, in: wallImage)
        case .ended:
            // the pan gesture ended, so do nothing
            break
        default:
            // handle any other cases here
            break
        }
    }
    
    class HoldCell: UICollectionViewCell {
    
    let holdView: UIImageView
    
    override init(frame: CGRect) {
    holdView = UIImageView()
    super.init(frame: frame)
    contentView.addSubview(holdView)
    holdView.translatesAutoresizingMaskIntoConstraints = false
    holdView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    holdView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    holdView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    holdView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
    }
    
    }
    
    func readDirectory(atPath path: String) -> [String] {
    do {
    return try fileManager.contentsOfDirectory(atPath: path)
    } catch {
    print("Error reading contents of directory: \(error)")
    return []
    }
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer, indexPath: IndexPath) {
    let wallImage = UIImageView()
    _ = gestureRecognizer.location(in: wallImage)
    
    switch gestureRecognizer.state {
    case .began:
    let holdDirectory = "Holds"
    _ = readDirectory(atPath: holdDirectory)
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: holdDirectory) {
    if fileManager.isReadableFile(atPath: holdDirectory) {
    do {
    let holdNames = try fileManager.contentsOfDirectory(atPath: holdDirectory)
    let HoldLibrary = holdNames.map { Hold(image: UIImage(named: $0)!, size: CGSize(width: 50, height: 50), rotation: 0) }
    _ = HoldLibrary[indexPath.item]
    }
    catch {
    print("An error occurred while trying to read the contents of the directory: \(error)")
    }
    } else {
    print("The file manager does not have permission to read the directory at the specified path.")
    }
    } else {
    print("The directory at the specified path does not exist.")
    }
    
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    longPressGesture.delegate = self
        holdView!.addGestureRecognizer(longPressGesture)
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    panGesture.delegate = self
        holdView!.addGestureRecognizer(panGesture)
    
    case .ended:
    // the long press gesture ended, so stop dragging the hold image view
        holdView!.isUserInteractionEnabled = true
    default:
    // handle any other cases here
    break
    }
    }

    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        guard let selectedHold = selectedHold,
              let wallImage = wallImage,
              let _ = holdView else { return }

        _ = gestureRecognizer.location(in: wallImage)
        _ = Hold(image: selectedHold, size: CGSize(width: 50, height: 50), rotation: 0)
  //      hold.center = location
   //     wallImage.addSubview(hold)
    }
    



    
    
    
}
