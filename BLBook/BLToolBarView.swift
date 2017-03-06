//
//  BLToolBarView.swift
//  BLBook
//
//  Created by bigliang on 2017/3/2.
//  Copyright © 2017年 5i5j. All rights reserved.
//

import UIKit

@objc enum ToolBarButtonTag:Int {
    case Small = 1,Normal,Big,Day,Night
}

@objc protocol BLToolBarViewDelegate {
    func didSelect(withToolBarView toolBar:BLToolBarView,index:Int) ;
}


class BLToolBarView: UIView {

    public var delegate:BLToolBarViewDelegate?;

    override init(frame: CGRect) {
        super.init(frame: frame)
        bl_initUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func bl_initUI(){
        self.backgroundColor = UIColor.white;
        let tags:[ToolBarButtonTag] = [.Small,
                                       .Normal,
                                       .Big,
                                       .Day,
                                       .Night
        ];
        let images:Array = ["font_size_smaller","font_size1","font_size_larger"]
        let width:CGFloat = 30.0
        let padding:CGFloat = (self.bounds.size.width - width*5.0)/6.0
        for i in 0..<images.count {
            let btn:UIButton = UIButton(frame: CGRect(x: padding + (padding + width)*CGFloat(i), y: (self.frame.size.height - width)/2, width: width, height: width));
            btn.setImage(UIImage(named: images[i]), for: UIControlState.normal)
            btn.tag = tags[i].rawValue
            btn.addTarget(self, action: #selector(self.buttonClick(btn:)), for: UIControlEvents.touchUpInside)
            self.addSubview(btn);
        }
        
        let colors:Array = [UIColor.green,UIColor .black]
        for i in 0..<colors.count {
            let btn:UIButton = UIButton(frame: CGRect(x: padding + (padding + width)*CGFloat(i + 3), y: (self.frame.size.height - width)/2, width: width, height: width));
            btn.backgroundColor = colors[i];
            btn.tag = tags[i+3].rawValue
            btn.addTarget(self, action: #selector(BLToolBarView.buttonClick(btn:)), for: UIControlEvents.touchUpInside)
            self.addSubview(btn);
        }
    }
    
    @objc private func buttonClick(btn:UIButton) {
        self.delegate?.didSelect(withToolBarView: self, index: btn.tag)
    }

}
