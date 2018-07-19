import { fromEvent } from 'rxjs'
import { map, filter } from 'rxjs/operators'
import { rxStore } from 'rxstatestore'

import styles from './style.css'

export default class Counter extends HTMLElement
  createdCallback: ->
    @Counter = rxStore(0,
      increment: (amount = 1) => (count) => count + amount
      decrement: (amount = 1) => (count) => count - amount
    )

  attachedCallback: ->
    # our observable number to render on changes
    @count$ = @Counter.$.subscribe((count) => @render(count))
    
    @click$ = fromEvent(this, 'click').pipe(
      filter((e) -> e.target.hasAttribute('data-action'))
      map((e) -> e.target.dataset.action)
    ).subscribe((action) => @Counter[action]())

  detachedCallback: ->
    @count$.unsubscribe()
    @click$.unsubscribe()

  attributeChangedCallback: (attr, oldVal, newVal) ->
  
  render: (count) ->
    # one could pick a vdom or hyperdom lib here
    @innerHTML = """
      <button data-action="decrement">-</button>
      <span>#{count}</span>
      <button data-action="increment">+</button>
    """

document.registerElement('rx-counter', Counter)