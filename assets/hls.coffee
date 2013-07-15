
forEachInGroup = (x, y, fn) ->
  for xx in [0..8]
    if xx isnt x then fn xx, y
  for yy in [0..8]
    if yy isnt y then fn x, yy
  for pos in [0..8]
    cx = Math.floor(x / 3) * 3 + (pos % 3)
    cy = Math.floor(y / 3) * 3 + Math.floor(pos / 3)
    if cx isnt x and cy isnt y then fn cx, cy

removeFromArray = (arr, el) ->
  if (idx = arr.indexOf(el)) isnt -1 then arr.splice idx, 1

class HLS

  @generateFilled: ->

    instance = new HLS

    x = 0
    y = 0
    err = 0
    last = null

    while y isnt 9

      if x is 0
        last = instance.deflate()

      ns = instance.board[y][x]

      if ns.length is 0
        if ++err > 50
          return HLS.generateFilled()
        else
          instance.inflate last
          x = 0
          continue

      n = ns[Math.floor(Math.random() * ns.length)]
      instance.fill x, y, n

      if ++x is 9
        x = 0
        y++

    instance

  @generateSudoku: ->

    filled = HLS.generateFilled()
    instance = new HLS

    fillRandom = ->
      sx = Math.floor(Math.random() * 9)
      sy = Math.floor(Math.random() * 9)
      for x in [0..8]
        for y in [0..8]
          cx = (sx + x) % 9
          cy = (sy + y) % 9
          if Array.isArray instance.board[cy][cx]
            instance.fill cx, cy, filled.board[cy][cx]
            return true
      return false

    while fillRandom()
      if instance.isSolvable()
        return { filled: filled, instance: instance }

  constructor: ->

    @board = [0..8].map -> [0..8].map -> [1..9]
    @numEmpty = 81

  print: ->
    console.log 'Board:'
    console.log @board.map((row) -> row.map((n) -> (if Array.isArray n then ' ' else n)).join '').join '\n'

  export: ->
    @board.map (row) -> row.map (cell) -> if Array.isArray cell then null else cell

  deflate: ->
    return JSON.stringify { board: @board, numEmpty: @numEmpty }

  inflate: (str) ->
    data = JSON.parse str
    @board = data.board
    @numEmpty = data.numEmpty

  @inflate: (str) ->
    instance = new HLS
    instance.inflate str
    return instance

  solve: ->

    while true

      fills = [].concat @singles(), @hiddenSingels()

      if fills.length is 0
        return false

      for f in fills
        @fill f.x, f.y, f.n

      if @numEmpty is 0
        return true

  isSolvable: ->

    data = @deflate()
    solvable = @solve()
    @inflate data

    return solvable

  fill: (x, y, n) ->

    unless Array.isArray @board[y][x]
      if @board[y][x] isnt n
        console.log 'p:', @board[y][x]
        console.log 'n:', n
        throw new Error('Inconsistent state')
      return false

    @board[y][x] = n
    @numEmpty--

    forEachInGroup x, y, (x, y) =>
      cell = @board[y][x]
      if Array.isArray cell
        removeFromArray cell, n

    return true

  forEach: (fn) ->
    # Optimize: http://jsperf.com/array-loop-sudoku
    for i in [0..80]
      x = i % 9
      y = Math.floor(i / 9)
      val = @board[y][x]
      if Array.isArray val
        fn x, y, val

  singles: ->

    ret = []

    @forEach (x, y, ns) ->
      if ns.length is 1
        ret.push { type: 'single', x: x, y: y, n: ns[0] }

    return ret

  hiddenSingels: ->

    ret = []

    for i in [1..9]

      for y in [0..8]
        c = null
        for x in [0..8]
          ns = @board[y][x]
          if Array.isArray ns
            if i in ns
              if c is null
                c = { type: 'hidden-single-row', x: x, y: y, n: i }
              else
                c = null
                break
        if c isnt null
          ret.push(c)

      for x in [0..8]
        c = null
        for y in [0..8]
          ns = @board[y][x]
          if Array.isArray ns
            if i in ns
              if c is null
                c = { type: 'hidden-single-col', x: x, y: y, n: i }
              else
                c = null
                break
        if c isnt null
          ret.push(c)

      for z in [0..8]
        c = null
        for p in [0..8]
          x = (z % 3) * 3 + (p % 3)
          y = Math.floor(z / 3) * 3 + Math.floor(p / 3)
          ns = @board[y][x]
          if Array.isArray ns
            if i in ns
              if c is null
                c = { type: 'hidden-single-zone', x: x, y: y, n: i }
              else
                c = null
                break
        if c isnt null
          ret.push(c)

    return ret

try
  module.exports = HLS
catch e
  window.HLS = HLS
