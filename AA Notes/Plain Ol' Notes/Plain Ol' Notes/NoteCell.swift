//
//  NoteCell.swift
//  Plain Ol' Notes
//
//  Created by Areum on 2017-04-04.
//  Copyright © 2017 Todd Perkins. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

 @IBOutlet weak var title: UILabel!
    
    func configureCell(note: Note) {
        
        title.text = note.title

        
    }
    
    

}
