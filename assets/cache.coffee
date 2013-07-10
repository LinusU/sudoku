
window.addEventListener 'load', ->
  window.applicationCache.addEventListener 'updateready', ->
    if window.applicationCache.status is window.applicationCache.UPDATEREADY
      window.applicationCache.swapCache()
      document.querySelector('.btn.update').classList.remove 'hide'
