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
   var body: String? = ""
}

class NoteViewModel: NSObject {
   let note = MutableProperty<Note?>(nil)

   let dateStamp = MutableProperty<String>("")
   let noteBody  = MutableProperty<String?>("")
   
   override init() {
      super.init()
      
      dateStamp <~ note.producer
         |> ignoreNil
         |> map { note in
            note.dateUpdated
         }
//         |> on(next: { date in
//            NSLog("Formatting date \(date)")
//         })
         |> self.formatUpdatedDate()

      noteBody <~ note.producer
         |> ignoreNil
         |> map { note in
            note.body
         }
         |> on(next: { value in
            NSLog("Updated note body!")
         })
   }
   
   convenience init(_ n: Note?) {
      self.init()
      note.put(n)
   }
   
   func formatUpdatedDate() -> Signal<NSDate, NoError> -> Signal<String, NoError> {
      return map { date in
         self.formatUpdatedDate(date)
      }
   }
   
   func formatUpdatedDate(date: NSDate) -> String {
      if NSCalendar.currentCalendar().isDateInToday(date) {
         return NSDateFormatter.localizedStringFromDate(date, dateStyle: .NoStyle, timeStyle: .ShortStyle)
      }
      else {
         return NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
      }
   }
   
   func updateTime() {
      self.note.value?.dateUpdated = NSDate()
   }
   
   func updateText(text: String?) {
      self.note.value?.body = text
      updateTime()
//      let newNote = Note()
//      newNote.body = text
//      self.note.put(newNote)
   }
}
