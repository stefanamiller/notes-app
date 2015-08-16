//
//  Note.swift
//  NotesApp
//
//  Created by Stefan Miller on 2015-08-15.
//  Copyright (c) 2015 Stefan Miller. All rights reserved.
//

import UIKit
import ReactiveCocoa

class Note: NSObject {
   var dateUpdated: NSDate = NSDate()
   var title: String = ""
}

class NoteViewModel: NSObject {
   let note = MutableProperty<Note?>(nil)
   let dateStamp = MutableProperty<String>("")
   
   override init() {
      let formatDate: Signal<NSDate, NoError> -> Signal<String, NoError> = map {
         date in
         return date.description
      }
      
      dateStamp <~ note.producer
         |> ignoreNil
         |> map { note in
            note.dateUpdated.description
         }
//      dateStamp <~ dateUpdated.producer |> formatDate
//      dateStamp = dateUpdated.producer.lift(dateMap)
   }
   
   convenience init(_ n: Note?) {
      self.init()
      note.put(n)
   }
}
