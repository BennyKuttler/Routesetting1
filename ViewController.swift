//
//  ViewController.swift
//  Routesetting
//
//  Created by Benny Kuttler on 12/22/22.
//
import UIKit

class FadeSegue: UIStoryboardSegue {
    override func perform() {
        let sourceViewController = self.source
        let destinationViewController = self.destination
        
        // Add the destination view as a subview of the source view
        sourceViewController.view.addSubview(destinationViewController.view)
        
        // Fade in the destination view
        destinationViewController.view.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            destinationViewController.view.alpha = 1
        }, completion: { (finished) in
            // Remove the source view controller and present the destination view controller
            sourceViewController.present(destinationViewController, animated: false, completion: nil)
        })
    }
}






class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var wallImage: UIImageView!
    @IBOutlet weak var holdView: UICollectionView!
    @IBOutlet weak var addHolds: UIButton!
    
    let fileManager = FileManager.default
    let imageDirectory = "Holds"
    var imageNames = [String]()
    var images = [UIImage]()
    var holdImages = [UIImage]()
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    
    
    
    
     /*  func shouldAutorotate() -> Bool {
     if let image = wallImage.image {
     let imageOrientation = image.imageOrientation
     let deviceOrientation = UIDevice.current.orientation
     
     if (imageOrientation == .left || imageOrientation == .right) && (deviceOrientation == .portrait || deviceOrientation == .portraitUpsideDown) {
     return true
     } else if (imageOrientation == .up || imageOrientation == .down) && (deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight) {
     return true
     }
     }
     
     return false
     } */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func readDirectory(atPath path: String) -> [String] {
            do {
                let fileNames = try fileManager.contentsOfDirectory(atPath: path)
                return fileNames
            } catch {
                print("Error reading contents of directory: \(error)")
                return []
            }
        }
        
        if let navController = self.navigationController {
            navController.navigationBar.barStyle = .default
        }
        self.navigationController?.navigationBar.barStyle = .default
        let fileManager = FileManager.default

        do {
            let holdDirectory = "/Users/bennykuttler/Desktop/Routesetting/Routesetting/Routesetting/Assets.xcassets/Holds"
            let holdDirectoryURL = URL(fileURLWithPath: holdDirectory)
            let attributes = [FileAttributeKey.posixPermissions: NSNumber(value: 0o644)]
            try fileManager.setAttributes(attributes, ofItemAtPath: holdDirectoryURL.path)
        } catch {
            print("Error reading contents of directory: \(error)")
        }

        let holdDirectory = "Holds"
        
        let holdFileNames = readDirectory(atPath: holdDirectory)
        _ = holdFileNames.map { UIImage(named: $0)! }
        
  /*      holdView.dataSource = self
        holdView.delegate = self
        holdView.register(HoldCell.self, forCellWithReuseIdentifier: "HoldCell")
        
        do {
            imageNames = try fileManager.contentsOfDirectory(atPath: imageDirectory)
        } catch {
            print("Error reading contents of directory: \(error)")
        }
        
        images = imageNames.map { UIImage(named: $0)! } */
        
        wallImage.contentMode = .scaleAspectFit
        
        longPressGestureRecognizer.minimumPressDuration = 0.5
        longPressGestureRecognizer.addTarget(self, action: #selector(handleLongPress(_:)))
    }
    
    override var shouldAutorotate: Bool {
        if let image = wallImage.image {
            let imageOrientation = image.imageOrientation
            let deviceOrientation = UIDevice.current.orientation
            
            if (imageOrientation == .up || imageOrientation == .down) && (deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight) {
                return true
            } else if (imageOrientation == .left || imageOrientation == .right) && (deviceOrientation == .portrait || deviceOrientation == .portraitUpsideDown) {
                return true
            }
        }
        
        return false
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight]
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let image = wallImage.image {
            let imageOrientation = image.imageOrientation
            let deviceOrientation = UIDevice.current.orientation
            
            if (imageOrientation == .left || imageOrientation == .right) && (deviceOrientation == .portrait || deviceOrientation == .portraitUpsideDown) {
                wallImage.contentMode = .scaleAspectFit
            } else if (imageOrientation == .up || imageOrientation == .down) && (deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight) {
                wallImage.contentMode = .scaleAspectFit
            }
        }
    }
    
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        func readDirectory(atPath path: String) -> [String] {
            do {
                let fileNames = try fileManager.contentsOfDirectory(atPath: path)
                return fileNames
            } catch {
                print("Error reading contents of directory: \(error)")
                return []
            }
        }
        if gestureRecognizer.state == .began {
            let holdDirectory = "Holds"
            
            let holdFileNames = readDirectory(atPath: holdDirectory)
            let holds = holdFileNames.map { UIImage(named: $0)! }
            
            // Get the selected hold image
            guard let cell = gestureRecognizer.view as? UICollectionViewCell,
                  let indexPath = holdView.indexPath(for: cell) else { return }
            
            let holdImage = holds[indexPath.item]
            
            // Create a new image view with the hold image
            let holdImageView = UIImageView(image: holdImage)
            wallImage.addSubview(holdImageView)
            
            // Add the image view to the wall image view as a subview
            wallImage.addSubview(holdImageView)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HoldCell", for: indexPath) as! HoldCell
        cell.holdView.image = images[indexPath.row]
        return cell
    }
    
    
    
    
    
    
    class HoldSelectionViewController: UICollectionViewController {
     var selectedHold: UIImage?
     var wallImage: UIImageView?
     var holdView: UICollectionView?
     let longPressGestureRecognizer = UILongPressGestureRecognizer()
     let panGestureRecognizer = UIPanGestureRecognizer()
     let fileManager = FileManager.default
     let holdDirectory = "Holds"
     var holdFileNames: [String] = []
     var holds: [UIImage] = []
     
     override func viewDidLoad() {
     super.viewDidLoad()
     
     
     
     collectionView.register(HoldCell.self, forCellWithReuseIdentifier: "HoldCell")
     if let wallImage = wallImage {
     wallImage.addGestureRecognizer(panGestureRecognizer)
     for cell in holdView?.visibleCells ?? [] {
     cell.addGestureRecognizer(longPressGestureRecognizer)
     }
     }
     
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
     
     func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
     guard let selectedHold = selectedHold else { return }
     
     _ = gestureRecognizer.location(in: wallImage)
     _ = Hold(image: selectedHold, size: CGSize(width: 50, height: 50), rotation: 0)
     // hold.center = location
     //wallImage?.addSubview(hold)
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
     holdView.addGestureRecognizer(longPressGesture)
     
     let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
     panGesture.delegate = self
     holdView.addGestureRecognizer(panGesture)
     
     case .ended:
     // the long press gesture ended, so stop dragging the hold image view
     holdView.isUserInteractionEnabled = true
     default:
     // handle any other cases here
     break
     }
     }
     
     
     
     
     
     
     @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
     if let holdImageView = gestureRecognizer.view {
     let translation = gestureRecognizer.translation(in: wallImage)
     holdImageView.center = CGPoint(x: holdImageView.center.x + translation.x, y: holdImageView.center.y + translation.y)
     gestureRecognizer.setTranslation(CGPoint.zero, in: wallImage)
     }
     }
     
     @IBAction func addWallButtonTapped(_ sender: UIButton) {
     let vc = UIImagePickerController()
     vc.sourceType = .photoLibrary
     vc.delegate = self
     vc.allowsEditing = true
     present(vc, animated: true)
     }
     
    @IBAction func addHoldsButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toHoldSelection", sender: self)
    /*    let holdSelectionVC = HoldSelectionViewController()
        holdSelectionVC.wallImage = wallImage
        holdSelectionVC.holdView = holdView
        if let nav = self.navigationController {
            nav.pushViewController(holdSelectionVC, animated: true)
        } else {
            present(holdSelectionVC, animated: true, completion: nil)
        } */
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let holdSelectionVC = segue.destination as! HoldSelectionViewController
        holdSelectionVC.wallImage = wallImage
        holdSelectionVC.holdView = holdView
    }


     }
     
    

    
    extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
                wallImage.image = image
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    

