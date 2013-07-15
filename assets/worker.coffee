
self.addEventListener 'message', (e) ->

  gen = HLS.generateSudoku e.data.level
  game = {
    puzzle: gen.instance.export()
    solution: gen.filled.export()
    difficulty: e.data.level
  }

  self.postMessage game
