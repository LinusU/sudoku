
window.addEventListener 'load', ->
  window.applicationCache.addEventListener 'updateready', ->
    if window.applicationCache.status is window.applicationCache.UPDATEREADY
      window.applicationCache.swapCache()
      if confirm('A new version of this app is available. Load it?')
        window.location.reload()
