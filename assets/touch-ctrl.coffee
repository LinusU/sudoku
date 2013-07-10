
class TouchCtrl
  constructor: ->
    @sudoku = null
    @el = document.createElement 'table'
    @el.className = 'touch-ctrl hide'
    document.body.appendChild @el
    row = null
    [1..9].forEach (n) =>
      if (n - 1) % 3 is 0
        row = document.createElement 'tr'
        @el.appendChild row
      btn = document.createElement 'td'
      btn.addEventListener 'touchstart', => @fill n
      btn.innerText = n
      row.appendChild btn
    row = document.createElement 'tr'
    @el.appendChild row
    btn = document.createElement 'td'
    btn.setAttribute 'colspan', 2
    btn.addEventListener 'touchstart', => @clear()
    btn.innerText = 'Clear'
    row.appendChild btn
    btn = document.createElement 'td'
    btn.addEventListener 'touchstart', => @hide()
    btn.innerText = 'Hide'
    row.appendChild btn
  setSudoku: (@sudoku) ->
    @sudoku.on 'touch', (data) =>
      @sudoku.select data.x, data.y
      @show()
  fill: (n)->
    if @sudoku
      @sudoku.fill(n)
    @hide()
  clear: ->
    if @sudoku
      @sudoku.clear()
    @hide()
  show: ->
    @el.classList.remove 'hide'
  hide: ->
    @el.classList.add 'hide'

window.TouchCtrl = TouchCtrl
