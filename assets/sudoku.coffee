
class Sudoku
  constructor: (@el) ->
    @el.classList.add 'sudoku-board'
    @selected = null
    @data = null
    @cells = []
    @history = []
    @_on = {}
  _fill: (x, y, cell, n) ->
    @data.input[y][x] = n
    cell.value = n
    cell.element.innerText = (if n is null then '' else n)
    if n in [null, @data.solution[y][x]]
      cell.element.classList.remove 'invalid'
    else
      cell.element.classList.add 'invalid'
    @emit 'input', { x: x, y: y, n: n }
  on: (ev, fn) ->
    (@_on[ev] ||= []).push fn
  emit: (ev, data) ->
    (@_on[ev] || []).forEach (fn) -> fn data
  load: (@data) ->
    while @el.firstChild
      @el.removeChild @el.firstChild
    @history = []
    @selected = null
    @cells = @data.puzzle.map (row) ->
      row.map (n) ->
        if n is null
          {
            type: 'user'
            value: null
            element: document.createElement 'div'
          }
        else
          {
            type: 'system'
            value: n
            element: document.createElement 'div'
          }
    if @data.input
      @data.input.forEach (row, y) =>
        row.forEach (val, x) =>
          if @cells[y][x].type is 'user'
            @cells[y][x].value = (val || null)
    else
      @data.input = [1..9].map -> [1..9].map -> null
    @cells.forEach (row, y) =>
      el = document.createElement 'div'
      el.className = 'sudoku-row'
      @el.appendChild el
      row.forEach (cell, x) =>
        el.appendChild cell.element
        cell.element.className = 'sudoku-cell ' + cell.type + (if cell.value not in [null, @data.solution[y][x]] then ' invalid' else '')
        cell.element.innerText = (if cell.value is null then '' else cell.value)
        cell.element.addEventListener 'click', (e) =>
          @emit 'click', { x: x, y: y }
        cell.element.addEventListener 'touchstart', (e) =>
          @emit 'touch', { x: x, y: y }
  cell: (x, y) ->
    @cells[y][x]
  select: (x, y) ->
    if @selected
      @selected.cell.element.classList.remove 'selected'
    @selected = { x: x, y: y, cell: @cell(x, y) }
    @selected.cell.element.classList.add 'selected'
  moveSelection: (dx, dy) ->
    if @selected
      @select (@selected.x + 9 + dx) % 9, (@selected.y + 9 + dy) % 9
    else
      @select (4 + dx), (4 + dy)
  undo: ->
    if @history.length
      move = @history.pop()
      @select move.x, move.y
      @_fill move.x, move.y, @selected.cell, move.n
  fill: (n) ->
    if @selected and @selected.cell.type is 'user'
      @history.push { x: @selected.x, y: @selected.y, n: @selected.cell.value }
      @_fill @selected.x, @selected.y, @selected.cell, n
  clear: ->
    if @selected and @selected.cell.type is 'user'
      @history.push { x: @selected.x, y: @selected.y, n: @selected.cell.value }
      @_fill @selected.x, @selected.y, @selected.cell, null
  provideHint: ->
    sx = Math.floor(Math.random() * 9)
    sy = Math.floor(Math.random() * 9)
    for x in [0..8]
      for y in [0..8]
        cx = (sx + x) % 9
        cy = (sy + y) % 9
        c = @cell cx, cy
        if c.value is null
          n = @data.solution[cy][cx]
          @select cx, cy
          @fill n
          return true
    return false
  isValid: ->

    val = (x, y) => @cell(x, y).value

    # Columns
    for x in [0..8]
      set = new Array 9
      for y in [0..8]
        n = val x, y
        if n is null
          return false
        else
          set[n - 1] = 1
      if set.join('') isnt '111111111'
        return false

    # Rows
    for y in [0..8]
      set = new Array 9
      for x in [0..8]
        n = val x, y
        if n is null
          return false
        else
          set[n - 1] = 1
      if set.join('') isnt '111111111'
        return false

    # Zones
    for z in [0..8]
      zx = (z % 3) * 3
      zy = Math.floor(z / 3) * 3
      set = new Array 9
      for p in [0..8]
        px = (p % 3)
        py = Math.floor(p / 3)
        n = val zx + px, zy + py
        if n is null
          return false
        else
          set[n - 1] = 1
      if set.join('') isnt '111111111'
        return false

    return true

window.Sudoku = Sudoku
