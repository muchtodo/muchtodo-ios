//
//  Styles.swift
//  MuchToDo
//
//  Created by Belle Beth Cooper on 28/7/18.
//  Copyright © 2018 Hello Code. All rights reserved.
//

import Foundation
import UIKit


enum Styles {
    
    public enum FontSize {
        public static let STANDARD: CGFloat = 14.0
        public static let SMALL: CGFloat = 13.0
        public static let LARGE: CGFloat = 17.0
        public static let HUGE: CGFloat = 19.0
    }
    
    
    public enum Spacing {
        public static let STANDARD: CGFloat = 8.0
        public static let DOUBLE: CGFloat = 16.0
        public static let HALF: CGFloat = 4.0
        public static let QUARTER: CGFloat = 2.0
        public static let TRIPLE: CGFloat = 24.0
        public static let QUAD: CGFloat = 32.0
        
        public static let INDENT: CGFloat = 20.0
    }
    
    
    public enum Colours {
        public enum Grey {
            public static let light = UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1.0) /*#eeeeee*/
            public static let dark = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) /*#cccccc*/
            public static let darker = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.0) /*#888888*/
            public static let darkest = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            public static let medium = UIColor(hex: "818894")
            public static let blueGrey = UIColor(hex: "4c5769")
            public static let pale = UIColor(hex: "ceced1")
            public static let mid = UIColor(hex: "a9b0b7")
        }
        
        public enum Pink {
            public static let medium = UIColor(red:0.93, green:0.38, blue:0.39, alpha:1.0)
            public static let dark = UIColor(red:0.86, green:0.20, blue:0.33, alpha:1.0)
            public static let red = UIColor(red:0.82, green:0.25, blue:0.33, alpha:1.0)
            public static let light = UIColor(red:0.98, green:0.81, blue:0.82, alpha:1.0)
        }
        
        public enum Purple {
            public static let darkBlue = UIColor(red:0.13, green:0.10, blue:0.40, alpha:1.0)
            public static let lightPink = UIColor(red:0.89, green:0.72, blue:0.83, alpha:1.0)
            public static let light = UIColor(red:0.62, green:0.35, blue:0.56, alpha:1.0)
            public static let veryLight = UIColor(red:0.75, green:0.69, blue:0.87, alpha:1.0)
            public static let dark = UIColor(red:0.46, green:0.29, blue:0.51, alpha:1.0)
        }
        
        public enum Green {
            public static let darkMint = UIColor(hex: "80afb1")
            public static let medMint = UIColor(hex: "94bcbc")
            public static let paleMint = UIColor(hex: "d1e1dd")
            public static let beige = UIColor(hex: "e5dad2")
            public static let pinkBeige = UIColor(hex: "efe4de")
        }
        
        public enum Theme {
            public static let iconTint = Purple.light
            public static let counterBackground = Purple.light
            public static let counterText = UIColor.white
            public static let navBarDarkest = Purple.darkBlue
            public static let navBarLightest = Purple.light
            public static let navBarTint = UIColor.white
            public static let newTaskBackground = Purple.dark
            public static let newTaskTint = UIColor.white
            public static let cellSelect = Grey.light
        }
    }
}


public extension UIColor {
    
    public convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}



