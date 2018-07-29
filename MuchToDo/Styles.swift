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
        }
        
        public enum Pink {
            public static let medium = UIColor(red:0.93, green:0.38, blue:0.39, alpha:1.0)
            public static let dark = UIColor(red:0.86, green:0.20, blue:0.33, alpha:1.0)
            public static let red = UIColor(red:0.82, green:0.25, blue:0.33, alpha:1.0)
            public static let light = UIColor(red:0.98, green:0.81, blue:0.82, alpha:1.0)
        }
    }

    
    
    
    
    
}



