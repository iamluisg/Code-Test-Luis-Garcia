//
//  AddCellView.swift
//  Code Test Luis Garcia
//
//  Created by Luis Garcia on 12/20/18.
//  Copyright © 2018 Luis Garcia. All rights reserved.
//

import UIKit

protocol AddCellDelegate {
    func addCellToSection(section: Int)
}

class AddCellView: UITableViewHeaderFooterView {

    @IBOutlet weak var addMessageLabel: UILabel!
//    @IBOutlet weak var view: UIView!
    
    var delegate: AddCellDelegate?
    var section: Int?
    
    /*
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
        let xib = UINib(nibName: "AddCellView", bundle: bundle)
        let view = xib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
 */
    
    @IBAction func addCell(_ sender: Any) {
        guard let section = self.section else { return }
        self.delegate?.addCellToSection(section: section)
    }
}
