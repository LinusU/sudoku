
class KeyboardCtrl

  constructor: ->
    @sudoku = null
    document.addEventListener 'keydown', (e) =>
      if @sudoku then @keyDown (e.keyCode || e.which)

  setSudoku: (@sudoku) ->
    @sudoku.on 'click', (data) =>
      @sudoku.select data.x, data.y

  keyDown: (key) ->

    # Arrow keys
    if 37 <= key <= 40
      dx = [-1,0,1,0][key - 37]
      dy = [0,-1,0,1][key - 37]
      @sudoku.moveSelection dx, dy

    # Number keys
    if 48 <= key <= 57
      @sudoku.fill (key - 48)

    # Space
    if key is 32
      @sudoku.clear()

window.KeyboardCtrl = KeyboardCtrl
