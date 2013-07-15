
HLS = require '../assets/hls.coffee'

gen = HLS.generateSudoku 3

gen.instance.print()
gen.filled.print()
