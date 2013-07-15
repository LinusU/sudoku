
getXY = (type, pos1, pos2) ->
  if type is 'row'
    return [pos2, pos1]
  if type is 'col'
    return [pos1, pos2]
  if type is 'zone'
    x = (pos1 % 3) * 3 + (pos2 % 3)
    y = Math.floor(pos1 / 3) * 3 + Math.floor(pos2 / 3)
    return [x, y]

forEachInGroup = (x, y, fn) ->
  for xx in [0..8]
    if xx isnt x then fn xx, y
  for yy in [0..8]
    if yy isnt y then fn x, yy
  for pos in [0..8]
    cx = Math.floor(x / 3) * 3 + (pos % 3)
    cy = Math.floor(y / 3) * 3 + Math.floor(pos / 3)
    if cx isnt x and cy isnt y then fn cx, cy

runEachGroup = (pre, fn, post) ->
  for t in ['row', 'col', 'zone']
    for p1 in [0..8]
      pre t, p1
      for p2 in [0..8]
        if fn(p1, p2) is false
          break
      post t, p1

removeFromArray = (arr, el) ->
  if (idx = arr.indexOf(el)) isnt -1 then arr.splice idx, 1

compareArray = (arr1, arr2) ->
  arr1.join('') is arr2.join('')

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

  @generateSudoku: (level) ->

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
      if instance.isSolvable level
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

  solve: (level) ->

    if level <= 0
      return (@numEmpty is 0)

    while true

      if level > 1
        @nakedPairs()

      if level > 0
        fills = [].concat @singles(), @hiddenSingels()

      if fills.length is 0
        return false

      for f in fills
        @fill f.x, f.y, f.n

      if @numEmpty is 0
        return true

  isSolvable: (level) ->

    data = @deflate()
    solvable = @solve level
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

    c = null
    t = ''
    i = 0
    ret = []

    pre = (type) ->
      c = null
      t = type
    fn = (p1, p2) =>
      [x, y] = getXY t, p1, p2
      ns = @board[y][x]
      if Array.isArray ns
        if i in ns
          if c is null
            c = { type: 'hidden-single-' + t, x: x, y: y, n: i }
          else
            c = null
            return false
      return true
    post = ->
      if c isnt null
        ret.push c

    for i in [1..9]
      runEachGroup pre, fn, post

    return ret

  nakedPairs: ->

    t = ''
    ret = []

    pre = (type) ->
      t = type
    fn = (p1, p2) =>
      [x, y] = getXY t, p1, p2
      ns = @board[y][x]

      if Array.isArray ns
        if ns.length is 2
          for i in [(p2+1)..8] by 1
            [xx, yy] = getXY t, p1, i
            nns = @board[yy][xx]
            if Array.isArray nns
              if compareArray ns, nns
                # hint = { type: 'naked-pair-' + t, pos: [[x, y], [xx, yy]], ns: [ns[0], ns[1]] }
                for j in [0..8]
                  if j isnt p2 and j isnt i
                    [xxx, yyy] = getXY t, p1, j
                    nnns = @board[yyy][xxx]
                    if Array.isArray nnns
                      removeFromArray nnns, ns[0]
                      removeFromArray nnns, ns[1]

    post = ->

    runEachGroup pre, fn, post

try
  module.exports = HLS
catch e
  @HLS = HLS
