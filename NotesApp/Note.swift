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
   
   var title: String? {
      get {
         var bodyLength = 0
         if let fullBody = body {
            bodyLength = count(fullBody)
         }
         if bodyLength > 0 {
            let firstNewLine = body?.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet())
            if let newLineIndex = firstNewLine?.startIndex {
               return body?.substringToIndex(newLineIndex);
            }
            else {
               return body
            }
         }
         else {
            return nil
         }
      }
   }

   func copy() -> Note {
      let copy = Note()
      copy.dateUpdated = dateUpdated
      copy.body = body
      return copy
   }
}
