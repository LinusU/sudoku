
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

    solver = new HLS()

    for x in [0..8]
      for y in [0..8]
        c = @cell x, y
        if c.value
          solver.fill x, y, c.value

    test = solver.hint()

    if test
      @visualizeHint test
    else
      throw new Error 'No hint computed'

  visualizeHint: (hint) ->

    body = document.querySelector 'body'
    canvas = document.createElement 'canvas'
    ctx = canvas.getContext '2d'

    bw = @el.clientWidth
    cw = Math.round bw / 9

    canvas.width = bw
    canvas.height = bw
    canvas.className = 'sudoku-hint'
    @el.appendChild canvas

    hintText = document.createElement 'div'
    hintText.className = 'sudoku-hint-text'
    @el.appendChild hintText

    div = document.createElement 'div'
    div.className = 'sudoku-click-trap'
    body.appendChild div

    evName = if ('ontouchstart' of window) then 'touchstart' else 'click'
    div.addEventListener evName, =>
      body.removeChild div
      @el.removeChild canvas
      @el.removeChild hintText
    , false

    ctx.scale cw, cw
    ctx.fillStyle = 'black'
    ctx.fillRect 0, 0, 9, 9

    @select hint.x, hint.y
    @fill hint.n

    switch hint.type
      when 'hidden-single-zone'
        for x in [0..8]
          for y in [0..8]
            c = @cell x, y
            if c.value is hint.n and (Math.floor(x / 3) is Math.floor(hint.x / 3) or Math.floor(y / 3) is Math.floor(hint.y / 3))
              ctx.clearRect x, y, 1, 1
        ctx.clearRect Math.floor(hint.x / 3) * 3, Math.floor(hint.y / 3) * 3, 3, 3
        hintText.innerText = 'Only possible placement in zone'

      when 'hidden-single-row'
        for x in [0..8]
          for y in [0..8]
            if y is hint.y then continue
            c = @cell x, y
            c2 = @cell x, hint.y
            if c.value is hint.n and (c2.value is null or Math.floor(y / 3) is Math.floor(hint.y / 3))
              ctx.clearRect x, y, 1, 1
        ctx.clearRect 0, hint.y, 9, 1
        hintText.innerText = 'Only possible placement in row'

      when 'hidden-single-col'
        for x in [0..8]
          for y in [0..8]
            if x is hint.x then continue
            c = @cell x, y
            c2 = @cell hint.x, y
            if c.value is hint.n and (c2.value is null or Math.floor(x / 3) is Math.floor(hint.x / 3))
              ctx.clearRect x, y, 1, 1
        ctx.clearRect hint.x, 0, 1, 9
        hintText.innerText = 'Only possible placement in column'

      when 'single'
        for i in [0..8]
          c = @cell hint.x, i
          if c.value
            ctx.clearRect hint.x, i, 1, 1
          c = @cell i, hint.y
          if c.value
            ctx.clearRect i, hint.y, 1, 1
          cx = (Math.floor(hint.x / 3) * 3) + i % 3
          cy = (Math.floor(hint.y / 3) * 3) + Math.floor(i / 3)
          c = @cell cx, cy
          if c.value
            ctx.clearRect cx, cy, 1, 1
        ctx.clearRect hint.x, hint.y, 1, 1
        hintText.innerText = 'Only possible value in cell'

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
