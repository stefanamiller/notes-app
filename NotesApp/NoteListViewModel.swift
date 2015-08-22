//
//  NoteListViewModel.swift
//  NotesApp
//
//  Created by Stefan Miller on 2015-08-18.
//  Copyright (c) 2015 Stefan Miller. All rights reserved.
//

import UIKit
import ReactiveCocoa

class NoteListViewModel: NSObject {
   typealias IndicesChangeSignal = Signal<Int,NoError>
   typealias IndicesMoveSignal   = Signal<(Int,Int),NoError>
   
   let notes = MutableProperty<[NoteViewModel]>([NoteViewModel]())
   
   let insertSignal: IndicesChangeSignal
   let removeSignal: IndicesChangeSignal
   let updateSignal: IndicesMoveSignal
   
   var addAction: CocoaAction!
   
   private let insertSink: IndicesChangeSignal.Observer
   private let removeSink: IndicesChangeSignal.Observer
   private let updateSink: IndicesMoveSignal.Observer
   
   override init() {
      
      let (insertPipeSig, insertPipeSink) = IndicesChangeSignal.pipe()
      insertSignal = insertPipeSig
      insertSink   = insertPipeSink
      
      let (removePipeSig, removePipeSink) = IndicesChangeSignal.pipe()
      removeSignal = removePipeSig
      removeSink   = removePipeSink
      
      let (updatePipeSig, updatePipeSink) = IndicesMoveSignal.pipe()
      updateSignal = updatePipeSig
      updateSink   = updatePipeSink
      
      super.init()
      
      let action = Action<UIBarButtonItem, Void, NoError> { [weak self] button in
         NSLog("Add Action!!!")
         self!.createNewNote()
         return SignalProducer.empty
      }
      addAction = action.unsafeCocoaAction
   }
   
   deinit {
      sendCompleted(insertSink)
      sendCompleted(removeSink)
      sendCompleted(updateSink)
   }
   
   func countOfNotes() -> Int {
      return notes.value.count
   }
   
   func noteViewModelAtIndex(index: Int) -> NoteViewModel {
      return notes.value[index]
   }
   
   func createNewNote() {
      var newNotes = notes.value
      let newViewModel = NoteViewModel(Note())
      
      newViewModel.updateSignal |> observe(next: { [weak self] updatedViewModel in
         self!.updateNote(updatedViewModel)
      })
      
      newNotes.insert(newViewModel, atIndex: 0)
      notes.put(newNotes)
      sendNext(insertSink, 0)
   }
   
   func deleteNoteAtIndex(index: Int) {
      var newNotes = notes.value
      newNotes.removeAtIndex(index)
      notes.put(newNotes)
      sendNext(removeSink, index)
   }
   
   func updateNote(viewModel: NoteViewModel) {
      
      let foundIndex = find(notes.value, viewModel)
      if let index = foundIndex {
         updateNoteAtIndex(index, viewModel)
      }
      
   }
   
   private func updateNoteAtIndex(index: Int, _ viewModel: NoteViewModel) {
      
      func sortNotesByUpdatedDate(inout notes: [NoteViewModel]) {
         sort(&notes, { (noteVM1: NoteViewModel, noteVM2: NoteViewModel) -> Bool in
            var noteDate1 = noteVM1.note?.dateUpdated
            var noteDate2 = noteVM2.note?.dateUpdated
            if let date1 = noteDate1, let date2 = noteDate2 {
               return date1.compare(date2) == NSComparisonResult.OrderedDescending
            }
            else {
               return false
            }
         })
      }
      
      var newNotes = notes.value
      sortNotesByUpdatedDate(&newNotes)
      
      let foundNewIndex = find(newNotes, viewModel)
      
      if let newIndex = foundNewIndex {
         notes.put(newNotes);
         sendNext(updateSink, (index, newIndex))
      }
   }
}
