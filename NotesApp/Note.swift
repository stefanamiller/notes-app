//
//  Note.swift
//  NotesApp
//
//  Created by Stefan Miller on 2015-08-15.
//  Copyright (c) 2015 Stefan Miller. All rights reserved.
//

import UIKit

class Note {
   var dateUpdated: NSDate = NSDate()
   var body: String? = ""

   func copy() -> Note {
      let copy = Note()
      copy.dateUpdated = dateUpdated
      copy.body = body
      return copy
   }
}
