//
//  ContactDetailHeaderView.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/24/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

class ContactDetailHeaderView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup() {
        self.view = loadViewFromXib()
        self.view.frame = bounds
        self.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(self.view)
        
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let xib = UINib(nibName: "ContactDetailHeaderView", bundle: bundle)
        let view = xib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
}
