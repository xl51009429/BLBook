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

    public weak var delegate:BLToolBarViewDelegate?;

    override init(frame: CGRect) {
        super.init(frame: frame)
        bl_initUI();
        bl_addBtnBorder();
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
        let images:Array = ["font_size_smaller_r","font_size_r","font_size_larger_r"]
        let width:CGFloat = 30.0
        let padding:CGFloat = (self.bounds.size.width - width*5.0)/6.0
        for i in 0..<images.count {
            let btn:UIButton = UIButton(frame: CGRect(x: padding + (padding + width)*CGFloat(i), y: (self.frame.size.height - width)/2, width: width, height: width));
            btn.setImage(UIImage(named: images[i]), for: UIControlState.normal)
            btn.tag = tags[i].rawValue
            btn.addTarget(self, action: #selector(self.buttonClick(btn:)), for: UIControlEvents.touchUpInside)
            btn.layer.borderColor = UIColor.white.cgColor
            self.addSubview(btn);
        }
        
        let colors:Array = [UIColor.green,UIColor .black]
        for i in 0..<colors.count {
            let btn:UIButton = UIButton(frame: CGRect(x: padding + (padding + width)*CGFloat(i + 3), y: (self.frame.size.height - width)/2, width: width, height: width));
            btn.backgroundColor = colors[i];
            btn.tag = tags[i+3].rawValue
            btn.addTarget(self, action: #selector(BLToolBarView.buttonClick(btn:)), for: UIControlEvents.touchUpInside)
            btn.layer.borderColor = UIColor.white.cgColor
            if i==0 {
                btn.setTitleColor(UIColor.black, for: UIControlState.normal)
                btn.setTitle("日", for: UIControlState.normal)
            }else{
                btn.setTitleColor(UIColor.white, for: UIControlState.normal)
                btn.setTitle("夜", for: UIControlState.normal)
            }
            self.addSubview(btn);
        }
    }
    
    func bl_addBtnBorder(){
        let btnNormal:UIButton = self.viewWithTag(ToolBarButtonTag.Normal.rawValue) as! UIButton
        let btnBig:UIButton = self.viewWithTag(ToolBarButtonTag.Big.rawValue) as! UIButton
        let btnSmall:UIButton = self.viewWithTag(ToolBarButtonTag.Small.rawValue) as! UIButton
        //字体添加边框
        let fontSize:Int = UserDefaults.standard.integer(forKey: "FontSize")
        if fontSize == Int(kFontSizeNormal) || fontSize == 0 {
            btnNormal.layer.borderWidth = 1;
            btnBig.layer.borderWidth = 0;
            btnSmall.layer.borderWidth = 0;
        }else if fontSize == Int(kFontSizeBig){
            btnNormal.layer.borderWidth = 0;
            btnBig.layer.borderWidth = 1;
            btnSmall.layer.borderWidth = 0;
        }else if fontSize == Int(kFontSizeSmall){
            btnNormal.layer.borderWidth = 0;
            btnBig.layer.borderWidth = 0;
            btnSmall.layer.borderWidth = 1;
        }
        
        let btnDay:UIButton = self.viewWithTag(ToolBarButtonTag.Day.rawValue) as! UIButton
        let btnNight:UIButton = self.viewWithTag(ToolBarButtonTag.Night.rawValue) as! UIButton
        //主题添加边框
        let theme:String? = UserDefaults.standard.string(forKey: "Theme")
        if theme == nil || theme == "day" {
            btnDay.layer.borderWidth = 1;
            btnNight.layer.borderWidth = 0;
        }else{
            btnDay.layer.borderWidth = 0;
            btnNight.layer.borderWidth = 1;
        }
    }
    
    @objc private func buttonClick(btn:UIButton) {
        self.delegate?.didSelect(withToolBarView: self, index: btn.tag)
        bl_addBtnBorder()
    }

}
