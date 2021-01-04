//
//  String+Extension.swift
//  BuildSwift
//
//  Created by xc on 2019/8/9.
//  Copyright © 2019 四川隧唐科技股份有限公司. All rights reserved.
//

import Foundation
import UIKit
extension String {
    
    //单行的宽高
    func size(_ font: UIFont) -> CGSize {
        
        let size = self.size(withAttributes: [NSAttributedString.Key.font:font])
        
        return size
    }
    
    //高度计算
    func height(_ font:UIFont,maxWidth : CGFloat) -> CGFloat {
        
        return self.boundingRect(with: CGSize.init(width: maxWidth, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin], attributes: [.font : font], context: nil).size.height
        
 
    }
    
    //带行距的高度计算
    func attributedHeight(_ font:UIFont,size:CGSize,lineSpace:CGFloat) -> CGRect {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        
        let rect = NSString(string: self).boundingRect(with: size, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedString.Key.font:font,NSAttributedString.Key.paragraphStyle:paragraphStyle], context: nil)
        return rect
    }
    
    //格式化小数
    func decimalNumber(scale: Int = 2) -> NSNumber {
        if Float(self) == 0 {
            return NSNumber(value: 0)
        }
        
        let roundUp = NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(scale), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        
        let number = NSDecimalNumber(string: self)
        let numberPlain = number.rounding(accordingToBehavior: roundUp)
        
        return numberPlain
    }
    
    //格式化小数
    func formatting(scale: Int = 2) -> String {
        
        let number = decimalNumber(scale: scale)
        
        return number.stringValue
    }
    
    
    
    
}
