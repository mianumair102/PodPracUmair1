//
//  RozeeUIView.swift
//  NaseebNetworksInc
//
//  Created by Mian Umair Nadeem on 30/11/2016.
//  Copyright © 2016 Mian Umair Nadeem. All rights reserved.
//

import UIKit
import SwiftHEXColors

public class RozeeUIView: UIView {

    // MARK: Variables
    @IBInspectable public var bgColorType:Int = 0
    @IBInspectable public var cornerRadius:Float = 0.0
    
    @IBInspectable public var borderHeight:Int = 0
    @IBInspectable public var borderColorType:Int = 0
    
    @IBInspectable public var addBottomShadow:Bool = false
    
    // MARK: Functions
    
    public override func draw(_ rect: CGRect)
    {
        
        // Set BackGround Color
        if(self.bgColorType != 0)
        {
            let colorString = FrameWorkStarter.startRozeeFrameWork.rozeeColorDictionary[bgColorType]
            
            UIColor(hexString: colorString!)?.setFill()
            UIRectFill(rect)
        }
        
        // Set Corner radius
        if(self.cornerRadius != 0)
        {
            self.layer.cornerRadius = CGFloat(self.cornerRadius)
            self.clipsToBounds = true
        }
        
        // Set Boder + color
        if(self.borderHeight != 0)
        {
            let borderColorString = FrameWorkStarter.startRozeeFrameWork.rozeeColorDictionary[borderColorType]
            self.layer.borderColor = UIColor(hexString: borderColorString!)?.cgColor
            self.layer.borderWidth = CGFloat(self.borderHeight)
            self.clipsToBounds = true
        }
        
        if(addBottomShadow){
            
            let image = UIImage(named :"shadow.png")
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(origin: CGPoint(x: 0, y: self.bounds.height-2), size: CGSize(width: self.bounds.width, height: 2))
            self.addSubview(imageView)
            
        }
        
        
 
    }
    
}
