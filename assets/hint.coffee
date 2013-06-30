
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

class Hint

  constructor: (board) ->

    @values = board.map (row) -> row.map (cell) -> cell.value
    @possibles = board.map (row) -> row.map (cell) -> (if cell.value then null else [1..9])

    @forEach (x, y, val) =>
      if val
        forEachInGroup x, y, (x, y) =>
          if @value(x, y) is null
            removeFromArray @possibles[y][x], val

  forEach: (fn) ->
    @values.forEach (row, y) ->
      row.forEach (val, x) ->
        fn x, y, val

  hints: ->
    [].concat @singles(), @hiddenSingles()

  value: (x, y) ->
    @values[y][x]

  singles: ->

    ret = []

    @forEach (x, y, val) =>
      if val is null
        if @possibles[y][x].length is 1
          ret.push { type: 'single', x: x, y: y, val: @possibles[y][x][0] }

    return ret

  hiddenSingles: ->

    ret = []

    for i in [1..9]

      for y in [0..8]
        c = null
        for x in [0..8]
          if @value(x, y) is null
            if i in @possibles[y][x]
              if c is null
                c = { type: 'hidden-single-row', x: x, y: y, val: i }
              else
                c = null
                break
        if c isnt null
          ret.push(c)

      for x in [0..8]
        c = null
        for y in [0..8]
          if @value(x, y) is null
            if i in @possibles[y][x]
              if c is null
                c = { type: 'hidden-single-col', x: x, y: y, val: i }
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
          if @value(x, y) is null
            if i in @possibles[y][x]
              if c is null
                c = { type: 'hidden-single-zone', x: x, y: y, val: i }
              else
                c = null
                break
        if c isnt null
          ret.push(c)

    return ret

window.Hint = Hint
