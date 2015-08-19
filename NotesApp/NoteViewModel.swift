//
//  NoteViewModel.swift
//  NotesApp
//
//  Created by Stefan Miller on 2015-08-18.
//  Copyright (c) 2015 Stefan Miller. All rights reserved.
//

import UIKit
import ReactiveCocoa

class NoteViewModel: NSObject {
   private let note = MutableProperty<Note?>(nil)
   
   let dateStamp = MutableProperty<String>("")
   let noteBody  = MutableProperty<String?>("")
   
   let editingEnabled: ConstantProperty<Bool>
   
   init(_ n: Note?) {

      editingEnabled = ConstantProperty(n != nil)
      super.init()
      
      setupBindings()
      self.note.put(n)
   }
   
   convenience override init() {
      self.init(nil)
   }
   
   func setupBindings() {
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
   
   func formatUpdatedDate() -> Signal<NSDate, NoError> -> Signal<String, NoError> {
      return map { date in
         self.formatUpdatedDate(date)
      }
   }
   
   func formatUpdatedDate(date: NSDate) -> String {
      if NSCalendar.currentCalendar().isDateInToday(date) {
         return NSDateFormatter.localizedStringFromDate(date, dateStyle: .NoStyle, timeStyle: .MediumStyle)
      }
      else {
         return NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .MediumStyle)
      }
   }
   
   func updateText(text: String?) {
      if let noteRaw = self.note.value {
         noteRaw.body = text
         noteRaw.dateUpdated = NSDate()
         note.put(noteRaw)
      }
   }
}
