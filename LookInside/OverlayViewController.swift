//
//  OverlayViewController.swift
//  LookInside
//
//  Created by Herryanto Siatono on 2/12/14.
//  Copyright (c) 2014 Demo. All rights reserved.
//

import UIKit

class OverlayVibrantLabel: UILabel {
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func tintColorDidChange() {
        self.textColor = self.tintColor
    }
}

class OverlayViewController: UIViewController {
    
    // MARK: Properties
    
    // Background and foreground views
    var backgroundView: UIVisualEffectView!
    var foregroundContentView: UIVisualEffectView!
    var foregroundContentScrollView: UIScrollView!
    
    // Effect
    var blurEffect: UIBlurEffect!
    
    // Image View
    var imageView: UIImageView!
    
    // Labels
    var hueLabel: OverlayVibrantLabel!
    var saturationLabel: OverlayVibrantLabel!
    var brightnessLabel: OverlayVibrantLabel!

    // Sliders
    var hueSlider: UISlider!
    var saturationSlider: UISlider!
    var brightnessSlider: UISlider!
    
    // Button
    var saveButton: UIButton!
    
    // Collection view cell
    var photoViewCell: PhotoCollectionViewCell! {
        didSet {
            self.configureCIObjects()
        }
    }
    
    // Processing queue
    var processingQueue: dispatch_queue_t!
    
    // Image effects
    var context: CIContext!
    var baseCIImage: CIImage!
    var colorControlsFilter: CIFilter!
    var hueAdjustFilter: CIFilter!
    
    
    // MARK: Init
    override init() {
        super.init()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Set custom presentation controller
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // MARK: Controller Methods
    
    override func viewDidLoad() {
        // Setup foreground and background views
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: self.blurEffect)
        self.foregroundContentView = UIVisualEffectView(effect: vibrancyEffect)
        
        self.backgroundView = UIVisualEffectView(effect: self.blurEffect)
        
        // Init Scroll View
        self.foregroundContentScrollView = UIScrollView(frame: self.view.frame)
        
        self.configureViews()
    }
    
    
    // MARK: Helper Methods
    
    func setup() {
        self.imageView = UIImageView()
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        
        self.processingQueue = dispatch_queue_create("Image Processing Queue", DISPATCH_QUEUE_SERIAL)
    }
    
    func configureCIObjects() {
        if self.context == nil {
            self.context = CIContext(options: nil)
        }
        
        self.baseCIImage = CIImage(CGImage: self.photoViewCell.image.CGImage)
    }
    
    func configureViews() {
        
        // Set Image View
        self.imageView.image = self.photoViewCell.image
        
        // Configure background and foreground views
        self.view.backgroundColor = UIColor.clearColor()
        
        self.backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.foregroundContentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.foregroundContentScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Configure labels & sliders
        self.hueLabel = OverlayVibrantLabel()
        self.hueSlider = self.configureSlider(["maximumValue": 10.0])
        
        self.saturationLabel = OverlayVibrantLabel()
        self.saturationSlider = self.configureSlider(["value": 1.0, "maximumValue": 2.0])
        
        self.brightnessLabel = OverlayVibrantLabel()
        self.brightnessSlider = self.configureSlider(["minimumValue": -0.5, "maximumValue": 0.5])
        
        // Save Button
        self.saveButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        self.saveButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.saveButton.setTitle(NSLocalizedString("Save", comment: "Save Button Title"), forState: UIControlState.Normal)
        self.saveButton.titleLabel?.font = UIFont.systemFontOfSize(32.0)
        self.saveButton.addTarget(self, action: "savePushed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Add background and foreground content scroll view to subviews
        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.foregroundContentScrollView)

        // Setup foreground content views
        self.foregroundContentScrollView.addSubview(self.foregroundContentView)

        self.foregroundContentView.contentView.addSubview(self.hueLabel)
        self.foregroundContentView.contentView.addSubview(self.hueSlider)
        self.foregroundContentView.contentView.addSubview(self.saturationLabel)
        self.foregroundContentView.contentView.addSubview(self.saturationSlider)
        self.foregroundContentView.contentView.addSubview(self.brightnessLabel)
        self.foregroundContentView.contentView.addSubview(self.brightnessSlider)
        self.foregroundContentView.contentView.addSubview(self.saveButton)
        self.foregroundContentView.contentView.addSubview(self.saveButton)
        
        self.foregroundContentScrollView.addSubview(self.imageView)
        
        // Configure constraints
        self.configureViewConstraints()
    }
    
    func configureSlider(keyedValues: Dictionary<NSObject, AnyObject>?) -> UISlider {
        let slider = UISlider()
        
        slider.setTranslatesAutoresizingMaskIntoConstraints(false)
        slider.addTarget(self, action: "sliderChanged:", forControlEvents: UIControlEvents.ValueChanged)
        slider.continuous = false // default is true

        // Set optional values
        slider.setValuesForKeysWithDictionary(keyedValues!)
        
        return slider
    }
    
    func configureViewConstraints() {
        var views = [
            "backgroundView": self.backgroundView,
            "foregroundContentScrollView": self.foregroundContentScrollView,
            "foregroundContentView": self.foregroundContentView,
            "hueLabel": hueLabel,
            "hueSlider": hueSlider,
            "saturationLabel": saturationLabel,
            "saturationSlider": saturationSlider,
            "brightnessLabel": brightnessLabel,
            "brightnessSlider": brightnessSlider,
            "imageView": imageView,
            "saveButton": saveButton
        ]
        
        self.createHorizontalAndVerticalConstraints("backgroundView", views: views)
        self.createHorizontalAndVerticalConstraints("foregroundContentView", views: views)
        self.createHorizontalAndVerticalConstraints("foregroundContentScrollView", views: views)
        
        self.createHorizontalConstraintsWithDefaultMargin("hueLabel", views: views)
        self.createHorizontalConstraintsWithDefaultMargin("hueSlider", views: views)
        self.createHorizontalConstraintsWithDefaultMargin("saturationLabel", views: views)
        self.createHorizontalConstraintsWithDefaultMargin("saturationSlider", views: views)
        self.createHorizontalConstraintsWithDefaultMargin("brightnessLabel", views: views)
        self.createHorizontalConstraintsWithDefaultMargin("brightnessSlider", views: views)
        self.createHorizontalConstraintsWithDefaultMargin("saveButton", views: views)
        
        self.createLayoutConstraints("H:|[imageView(==foregroundContentScrollView)]|", views: views)
        
        self.createLayoutConstraints("V:|-(>=30)-[hueLabel]-[hueSlider]-[saturationLabel]-[saturationSlider]-[brightnessLabel]-[brightnessSlider]-[saveButton]-(>=10)-[imageView(==200)]|", views: views)
        
   
        // Call slider changed, to populate the label
        self.sliderChanged(nil)
    }
    
    func createHorizontalAndVerticalConstraints(viewName: String, views: [NSObject:AnyObject]) {
        self.createLayoutConstraints("H:|[\(viewName)]|", views: views)
        self.createLayoutConstraints("V:|[\(viewName)]|", views: views)
    }
    
    func createHorizontalConstraintsWithDefaultMargin(viewName: String, views: [NSObject:AnyObject]) {
        self.createLayoutConstraints("H:|-[\(viewName)]-|", views: views)
    }
    
    func createLayoutConstraints(format: String, views: [NSObject:AnyObject]) {
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
    
    func applyEffectsToImageWithHue(hue: Float, saturation: Float, brightness: Float) {
        dispatch_async(self.processingQueue, {
            if self.colorControlsFilter == nil {
                self.colorControlsFilter = CIFilter(name: "CIColorControls")
            }
            
            // Adjust saturation and brightness
            self.colorControlsFilter.setValue(self.baseCIImage, forKey: kCIInputImageKey)
            self.colorControlsFilter.setValue(saturation, forKey: "inputSaturation")
            self.colorControlsFilter.setValue(brightness, forKey: "inputBrightness")
            var outputImage = self.colorControlsFilter.valueForKey(kCIOutputImageKey) as CIImage
            
            // Adjust hue
            if self.hueAdjustFilter == nil {
                self.hueAdjustFilter = CIFilter(name: "CIHueAdjust")
            }
            self.hueAdjustFilter.setValue(outputImage, forKey: kCIInputImageKey)
            self.hueAdjustFilter.setValue(hue, forKey: "inputAngle")
            outputImage = self.hueAdjustFilter.valueForKey(kCIOutputImageKey) as CIImage
            
            // Convert CIImage to UIImage
            let imageSize = self.photoViewCell.image.size
            let cgImage = self.context.createCGImage(outputImage, fromRect: CGRectMake(0, 0, imageSize.width, imageSize.height))
            let image = UIImage(CGImage: cgImage)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.imageView.image = image
            })
        })
    }
    
    // MARK: Actions
    
    func sliderChanged(sender: AnyObject!) {
        let hue = self.hueSlider.value
        let saturation = self.saturationSlider.value
        let brightness = self.brightnessSlider.value
        
        self.hueLabel.text = String(format: NSLocalizedString("Hue: %f", comment: "Hue label format"), hue)
        self.saturationLabel.text = String(format: NSLocalizedString("Saturation: %f", comment: "Saturation label format"), saturation)
        self.brightnessLabel.text = String(format: NSLocalizedString("Brightness: %f", comment: "Brightness label format"), brightness)
        
        // Apply effects to image
        self.applyEffectsToImageWithHue(hue, saturation: saturation, brightness: brightness)
    }
    
    func savePushed(sender: AnyObject!) {
        self.photoViewCell.image = self.imageView.image
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

