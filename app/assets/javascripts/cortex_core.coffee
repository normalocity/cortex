$ ->
  window.minThoughtWallRefreshDelay = 5000
  window.maxThoughtLength = 65500

  window.overlayDiv = $('#overlay')
  window.overlayContentDiv = $('#overlay-content')

  window.renderTimestampDiv = $('#render_timestamp')
  window.nextThoughtWallRefreshDiv = $('#next_refresh')

  window.newThoughtTextarea = $('#thought_text')
  window.newThoughtTextRemainingCountDiv = $('#thought-new-remaining-characters')

  window.thoughtListDiv = $("#thought-list")

  window.focusOnNewThoughtText = ( ->
    newThoughtTextarea.focus()
  )

  window.getOverlayIsVisible = ( ->
    (overlayDiv.css('display') != 'none')
  )

  window.getCurrThoughtWallRefreshDelay = ( ->
    delayFromDOM = parseInt(nextThoughtWallRefreshDiv.html())
    console.log delayFromDOM
    if (isNaN(delayFromDOM) || delayFromDOM < minThoughtWallRefreshDelay)
      minThoughtWallRefreshDelay
    else
      delayFromDOM
  )

  window.getRenderTimestamp = ( ->
    renderTimestampDiv.html()
  )

  window.setRenderTimestamp = ((renderTimestamp) ->
    renderTimestampDiv.html(renderTimestamp)
  )

  window.setNextThoughtWallRefreshDelay = ((nextRefreshDelay) ->
    nextThoughtWallRefreshDiv.html(nextRefreshDelay)
  )

  window.clearNewThoughtForm = ( ->
    newThoughtTextarea.val('')
    newThoughtTextRemainingCountDiv.html('remaining: ' + (maxThoughtLength - newThoughtTextarea.val().length))
  )

  window.refreshPageNow = ( ->
    $.get document.URL+".js?since="+getRenderTimestamp()+"&next_refresh="+getCurrThoughtWallRefreshDelay()
    , (data) ->
      console.log data
  )
