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
         self!.updateSortingOfNote(updatedViewModel)
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
   
   func updateSortingOfNote(viewModel: NoteViewModel) {
      
      let foundIndex = find(notes.value, viewModel)
      if let index = foundIndex {
         if foundIndex > 0 {
            reorderUpdatedNote(viewModel, atIndex: index)
         }
      }
      
   }
   
   private func reorderUpdatedNote(viewModel: NoteViewModel, atIndex: Int) {
      
      func findNewNotesIndexFor(viewModel: NoteViewModel, fromIndex: Int) -> Int {
         var dateUpdated = viewModel.note?.dateUpdated
         var newIndex = fromIndex
         for i in reverse(0...fromIndex-1) {
            var otherDateUpdated = notes.value[i].note?.dateUpdated
            if let date1 = dateUpdated, let date2 = otherDateUpdated {
               if date1.compare(date2) == NSComparisonResult.OrderedDescending {
                  newIndex = i
               }
               else {
                  break
               }
            }
         }
         return newIndex
      }
      
      let newIndex = findNewNotesIndexFor(viewModel, atIndex)
      
      if newIndex != atIndex {
         var newNotes = notes.value
         newNotes.removeAtIndex(atIndex)
         newNotes.insert(viewModel, atIndex: newIndex)
         notes.put(newNotes);
         sendNext(updateSink, (atIndex, newIndex))
      }
   }
}
