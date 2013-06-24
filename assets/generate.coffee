
generateSudoku = ->

  canPlace = (x, y, n) ->
    sx = Math.floor(x / 3) * 3
    sy = Math.floor(y / 3) * 3
    for i in [0..8]
      if obj.data[i][x] is n then return false
      if obj.data[y][i] is n then return false
      cx = sx + (i % 3)
      cy = sy + Math.floor(i / 3)
      if obj.data[cy][cx] is n then return false
    return true

  pickRandom = (x, y) ->
    n = 1 + Math.floor( Math.random() * 9 )
    for i in [0..8]
      if canPlace x, y, ((n + i) % 9) + 1
        return ((n + i) % 9) + 1
    return false

  clearRow = (y) ->
    obj.data[y] = [1..9].map -> 0

  obj =
    data: [1..9].map -> [1..9].map -> 0
    solution: []

  c = 0
  x = 0
  y = 0
  done = false

  until done
    n = pickRandom x, y
    if n is false
      c++
      if c > 2000
        throw new Error('Should this really happen?')
      else
        clearRow y
        x = 0
    else
      obj.data[y][x] = n
      if ++x > 8
        x = 0
        if ++y > 8
          done = true

  obj.solution = JSON.parse JSON.stringify obj.data

  #FIXME

window.generateSudoku = generateSudoku
