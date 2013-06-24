
sudoku = require 'sudoku'

format = (sudoku) ->
  chunks = (arr) ->
    r = []
    for i in [0..arr.length - 1] by 9
      r.push arr.slice i, i + 9
    return r

  chunks sudoku.map (e) ->
    if e is null then null else e + 1

process.on 'message', (msg) ->
  puzzle = sudoku.makepuzzle()
  solution = sudoku.solvepuzzle puzzle
  difficulty = sudoku.ratepuzzle puzzle, 4
  process.send
    puzzle: format puzzle
    solution: format solution
    difficulty: difficulty
