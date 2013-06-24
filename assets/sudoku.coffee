
class Sudoku
  constructor: (@el) ->
    @el.classList.add 'sudoku-board'
    @selected = null
    @data = null
    @cells = []
    @_on = {}
  on: (ev, fn) ->
    (@_on[ev] ||= []).push fn
  emit: (ev, data) ->
    (@_on[ev] || []).forEach (fn) -> fn data
  load: (@data) ->
    while @el.firstChild
      @el.removeChild @el.firstChild
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
        cell.element.className = 'sudoku-cell ' + cell.type
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
  fill: (n) ->
    if @selected and @selected.cell.type is 'user'
      @data.input[@selected.y][@selected.x] = n
      @selected.cell.value = n
      @selected.cell.element.innerText = n
      @emit 'input', { x: @selected.x, y: @selected.y, n: n }
  clear: ->
    if @selected and @selected.cell.type is 'user'
      @data.input[@selected.y][@selected.x] = null
      @selected.cell.value = null
      @selected.cell.element.innerText = ''
      @emit 'input', { x: @selected.x, y: @selected.y, n: null }
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
