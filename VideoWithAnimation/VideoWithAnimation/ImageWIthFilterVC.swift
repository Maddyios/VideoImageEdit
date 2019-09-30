//
//  ImageWIthFilterVC.swift
//  VideoWithAnimation
//
//  Created by Maulik Pandya on 29/09/19.
//  Copyright © 2019 Maulik Pandya. All rights reserved.
//

import UIKit

class ImageWIthFilterVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imgForFilter: UIImageView!
    @IBOutlet weak var collView: UICollectionView!
    
    var aCIImage = CIImage();
    var contrastFilter: CIFilter!;
    var brightnessFilter: CIFilter!;
    var context = CIContext();
    var outputImage = CIImage();
    var newUIImage = UIImage();
    
    let arrFilters = ["", "CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
    
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnAddImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func sliderBrightness(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.brightnessFilter.setValue(NSNumber(value: sender.value), forKey: "inputBrightness");
            self.outputImage = self.brightnessFilter.outputImage!
            let imageRef = self.context.createCGImage(self.outputImage, from: self.outputImage.extent)
            self.newUIImage = UIImage(cgImage: imageRef!)
            self.imgForFilter.image = self.newUIImage;
        }
    }
    
    func changeBrightness(imgView : UIImageView, value: CGFloat, image: UIImage){
        
    }
    
    @IBAction func sliderContrast(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.contrastFilter.setValue(NSNumber(value: sender.value), forKey: "inputContrast")
            self.outputImage = self.contrastFilter.outputImage!
            let cgimg = self.context.createCGImage(self.outputImage, from: self.outputImage.extent)
            self.newUIImage = UIImage(cgImage: cgimg!)
            self.imgForFilter.image = self.newUIImage;
        }
    }
    
    @IBAction func sliderSeturation(_ sender: Any) {
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        self.imgForFilter.image = image
        
        let aUIImage = image;
        let aCGImage = aUIImage.cgImage;
        aCIImage = CIImage(cgImage: aCGImage!)
        context = CIContext(options: nil);
        contrastFilter = CIFilter(name: "CIColorControls");
        contrastFilter.setValue(aCIImage, forKey: "inputImage")
        brightnessFilter = CIFilter(name: "CIColorControls");
        brightnessFilter.setValue(aCIImage, forKey: "inputImage")
        
        collView.reloadData()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ImageWIthFilterVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width/3.0) - 8.0, height: (UIScreen.main.bounds.width/3.0) - 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (imgForFilter.image != nil) ? arrFilters.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellWithFilter", for: indexPath) as! CellWithFilter
        DispatchQueue.main.async {
            let aImg = self.imgForFilter.image!.addFilter(filter: self.arrFilters[indexPath.item])
            aCell.imgWithFilter.image = aImg
        }
        return aCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let aImg = imgForFilter.image!.addFilter(filter: arrFilters[indexPath.item])
        imgForFilter.image = aImg
    }
    
    
}


extension UIImage {
    func addFilter(filter : String) -> UIImage {
        
        if filter == "" {
            return self
        }
        
        let filter = CIFilter(name: filter)
        // convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        // get output CIImage, render as CGImage first to retain proper UIImage scale
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        //Return the image
        return UIImage(cgImage: cgImage!)
    }
}
