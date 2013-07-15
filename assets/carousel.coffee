
instance = null
selectedId = null

window.carousel =
  selectedId: -> selectedId
  update: ->

    if instance
      instance.destroy()
      document.querySelector('#slider').innerHTML = ''

    list = game.list()
    instance = new SwipeView '#slider', { numberOfPages: list.length, loop: false }

    selectedId = list[0].id
    document.querySelector('#indicator').innerHTML = (new Array(list.length + 1).join('<b></b>'))
    document.querySelector('#indicator b').className = 'active'

    for i in [0..2]
      do ->
        page = (if i is 0 then list.length else i) - 1
        data = list[page % list.length]

        el = document.createElement 'div'
        el.classList.add 'game'
        thumb = document.createElement 'div'
        thumb.className = 'thumb'
        diff = document.createElement 'div'
        diff.className = 'diff'
        diff.innerHTML = do (d = data.game.difficulty) ->
          if d is 1 then return '<i></i><b></b><b></b><b></b>'
          if d is 2 then return '<i></i><i></i><b></b><b></b>'
          if d is 3 then return '<i></i><i></i><i></i><b></b>'
          if d is 4 then return '<i></i><i></i><i></i><i></i>'
          throw new Error 'Unknown difficulty'
        el.sudokuInstance = new Sudoku thumb
        el.sudokuInstance.load data.game
        el.appendChild thumb
        el.appendChild diff
        instance.masterPages[i].appendChild el

    instance.onFlip ->
      selectedId = list[instance.pageIndex].id
      document.querySelector('#indicator .active').className = ''
      document.querySelectorAll('#indicator b')[instance.pageIndex].className = 'active'
      for i in [0..2]
        upcoming = instance.masterPages[i].dataset.upcomingPageIndex
        data = list[upcoming % list.length]
        if upcoming isnt instance.masterPages[i].dataset.pageIndex
          el = instance.masterPages[i].querySelector('.game')
          el.sudokuInstance.load data.game
          diff = el.querySelector '.diff'
          diff.innerHTML = do (d = data.game.difficulty) ->
            if d is 1 then return '<i></i><b></b><b></b><b></b>'
            if d is 2 then return '<i></i><i></i><b></b><b></b>'
            if d is 3 then return '<i></i><i></i><i></i><b></b>'
            if d is 4 then return '<i></i><i></i><i></i><i></i>'
            throw new Error 'Unknown difficulty'
