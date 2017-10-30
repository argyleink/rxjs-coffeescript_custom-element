import { Subject } from 'rxjs/Subject'
import { BehaviorSubject } from 'rxjs/BehaviorSubject'
import 'rxjs/add/operator/map'
import 'rxjs/add/operator/merge'
import 'rxjs/add/operator/scan'

export Store = (initial_state, reducers) ->
  streams = {}
  actions = {}

  makeSubject = (action) ->
    subject$                = new Subject()
    streams["#{action}$"]   = subject$.map(reducers[action])
    actions[action]         = (args) => subject$.next(args)
  
  makeSubject action for action of reducers

  store$ = new BehaviorSubject(initial_state)
    .merge(...Object.values(streams))
    .scan((state, reducer) => reducer(state))
  
  return {store$, actions}

export Logger = (prefix, observable) ->
  return observable.scan((prevState, nextState) =>
    console.groupCollapsed("#{prefix}:")

    console.log("%c prev state:", "color: #999999; font-weight: bold", prevState)
    console.log("%c next state:", "color: #4CAF50; font-weight: bold", nextState)

    console.groupEnd()
    return nextState
  ).subscribe()