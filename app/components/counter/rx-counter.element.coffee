import { Observable } from 'rxjs/Observable'
import 'rxjs/add/observable/fromEvent'
import 'rxjs/add/operator/filter'
import 'rxjs/add/operator/map'

import {Store, Logger} from '../../utilities/rxstore.coffee'
import styles from './style.css'

export default class Counter extends HTMLElement
  createdCallback: ->
    # Store from seed, followed by object of reducers
    @Counter = Store(0,
      increment: (amount = 1) => (count) => count + amount
      decrement: (amount = 1) => (count) => count - amount
    )

    # opt into nice state change logs
    Logger('Counter', @Counter.store$)

  attachedCallback: ->
    # our observable number to render on changes
    @count$ = @Counter.store$.subscribe((count) => @render(count))
    
    @clicks$ = Observable.fromEvent(this, 'click')
      .filter((e) -> e.target.hasAttribute('data-action'))
      .map((e) -> e.target.dataset.action)
      .subscribe((action) => @Counter.actions[action]())

  detachedCallback: ->
    @count$.unsubscribe()
    @clicks$.unsubscribe()

  attributeChangedCallback: (attr, oldVal, newVal) ->
  
  render: (count) ->
    # one could pick a vdom or hyperdom lib here
    @innerHTML = """
      <button data-action="decrement">-</button>
      <span>#{count}</span>
      <button data-action="increment">+</button>
    """

document.registerElement('rx-counter', Counter)