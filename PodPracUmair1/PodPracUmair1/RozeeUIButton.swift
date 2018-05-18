//
//  RozeeUIButton.swift
//  NaseebNetworksInc
//
//  Created by Mian Umair Nadeem on 05/12/2016.
//  Copyright © 2016 Mian Umair Nadeem. All rights reserved.
//

import UIKit

public class RozeeUIButton: UIButton
{
    
    // MARK: Variables
    @IBInspectable public var textColorType:Int = 0
    
    @IBInspectable public var bgColorType:Int = 0
    @IBInspectable public var cornerRadius:Float = 0.0
    
    @IBInspectable public var borderHeight:Int = 0
    @IBInspectable public var borderColorType:Int = 0
    
    // MARK: Functions

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func draw(_ rect: CGRect)
    {
        
        // Set TextColor
        if(self.textColorType != 0)
        {
            let colorString = FrameWorkStarter.startRozeeFrameWork.rozeeColorDictionary[textColorType]
            
            self.setTitleColor(UIColor(hexString: colorString!), for: UIControlState.normal)
            //self.titleLabel?.textColor = UIColor(hexString: colorString!)
        }
        
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
    }
    

}
