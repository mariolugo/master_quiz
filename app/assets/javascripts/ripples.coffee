### Copyright 2014+, Federico Zivolo, LICENSE at https://github.com/FezVrasta/bootstrap-material-design/blob/master/LICENSE.md ###

### globals jQuery, navigator ###

(($, window, document) ->

  ###*
  # Create the main plugin function
  ###

  Ripples = (element, options) ->
    self = this
    @element = $(element)
    @options = $.extend({}, defaults, options)
    @_defaults = defaults
    @_name = ripples
    @init()
    return

  'use strict'

  ###*
  # Define the name of the plugin
  ###

  ripples = 'ripples'

  ###*
  # Get an instance of the plugin
  ###

  self = null

  ###*
  # Define the defaults of the plugin
  ###

  defaults = {}

  ###*
  # Initialize the plugin
  ###

  Ripples::init = ->
    $element = @element
    $element.on 'mousedown touchstart', (event) ->

      ###*
      # Verify if the user is just touching on a device and return if so
      ###

      if self.isTouch() and event.type == 'mousedown'
        return

      ###*
      # Verify if the current element already has a ripple wrapper element and
      # creates if it doesn't
      ###

      if !$element.find('.ripple-container').length
        $element.append '<div class="ripple-container"></div>'

      ###*
      # Find the ripple wrapper
      ###

      $wrapper = $element.children('.ripple-container')

      ###*
      # Get relY and relX positions
      ###

      relY = self.getRelY($wrapper, event)
      relX = self.getRelX($wrapper, event)

      ###*
      # If relY and/or relX are false, return the event
      ###

      if !relY and !relX
        return

      ###*
      # Get the ripple color
      ###

      rippleColor = self.getRipplesColor($element)

      ###*
      # Create the ripple element
      ###

      $ripple = $('<div></div>')
      $ripple.addClass('ripple').css
        'left': relX
        'top': relY
        'background-color': rippleColor

      ###*
      # Append the ripple to the wrapper
      ###

      $wrapper.append $ripple

      ###*
      # Make sure the ripple has the styles applied (ugly hack but it works)
      ###

      do ->
        window.getComputedStyle($ripple[0]).opacity

      ###*
      # Turn on the ripple animation
      ###

      self.rippleOn $element, $ripple

      ###*
      # Call the rippleEnd function when the transition "on" ends
      ###

      setTimeout (->
        self.rippleEnd $ripple
        return
      ), 500

      ###*
      # Detect when the user leaves the element
      ###

      $element.on 'mouseup mouseleave touchend', ->
        $ripple.data 'mousedown', 'off'
        if $ripple.data('animating') == 'off'
          self.rippleOut $ripple
        return
      return
    return

  ###*
  # Get the new size based on the element height/width and the ripple width
  ###

  Ripples::getNewSize = ($element, $ripple) ->
    Math.max($element.outerWidth(), $element.outerHeight()) / $ripple.outerWidth() * 2.5

  ###*
  # Get the relX
  ###

  Ripples::getRelX = ($wrapper, event) ->
    wrapperOffset = $wrapper.offset()
    if !self.isTouch()

      ###*
      # Get the mouse position relative to the ripple wrapper
      ###

      event.pageX - (wrapperOffset.left)
    else

      ###*
      # Make sure the user is using only one finger and then get the touch
      # position relative to the ripple wrapper
      ###

      event = event.originalEvent
      if event.touches.length == 1
        return event.touches[0].pageX - (wrapperOffset.left)
      false

  ###*
  # Get the relY
  ###

  Ripples::getRelY = ($wrapper, event) ->
    wrapperOffset = $wrapper.offset()
    if !self.isTouch()

      ###*
      # Get the mouse position relative to the ripple wrapper
      ###

      event.pageY - (wrapperOffset.top)
    else

      ###*
      # Make sure the user is using only one finger and then get the touch
      # position relative to the ripple wrapper
      ###

      event = event.originalEvent
      if event.touches.length == 1
        return event.touches[0].pageY - (wrapperOffset.top)
      false

  ###*
  # Get the ripple color
  ###

  Ripples::getRipplesColor = ($element) ->
    color = if $element.data('ripple-color') then $element.data('ripple-color') else window.getComputedStyle($element[0]).color
    color

  ###*
  # Verify if the client browser has transistion support
  ###

  Ripples::hasTransitionSupport = ->
    thisBody = document.body or document.documentElement
    thisStyle = thisBody.style
    support = thisStyle.transition != undefined or thisStyle.WebkitTransition != undefined or thisStyle.MozTransition != undefined or thisStyle.MsTransition != undefined or thisStyle.OTransition != undefined
    support

  ###*
  # Verify if the client is using a mobile device
  ###

  Ripples::isTouch = ->
    /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test navigator.userAgent

  ###*
  # End the animation of the ripple
  ###

  Ripples::rippleEnd = ($ripple) ->
    $ripple.data 'animating', 'off'
    if $ripple.data('mousedown') == 'off'
      self.rippleOut $ripple
    return

  ###*
  # Turn off the ripple effect
  ###

  Ripples::rippleOut = ($ripple) ->
    $ripple.off()
    if self.hasTransitionSupport()
      $ripple.addClass 'ripple-out'
    else
      $ripple.animate { 'opacity': 0 }, 100, ->
        $ripple.trigger 'transitionend'
        return
    $ripple.on 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', ->
      $ripple.remove()
      return
    return

  ###*
  # Turn on the ripple effect
  ###

  Ripples::rippleOn = ($element, $ripple) ->
    size = self.getNewSize($element, $ripple)
    if self.hasTransitionSupport()
      $ripple.css(
        '-ms-transform': 'scale(' + size + ')'
        '-moz-transform': 'scale(' + size + ')'
        '-webkit-transform': 'scale(' + size + ')'
        'transform': 'scale(' + size + ')').addClass('ripple-on').data('animating', 'on').data 'mousedown', 'on'
    else
      $ripple.animate {
        'width': Math.max($element.outerWidth(), $element.outerHeight()) * 2
        'height': Math.max($element.outerWidth(), $element.outerHeight()) * 2
        'margin-left': Math.max($element.outerWidth(), $element.outerHeight()) * -1
        'margin-top': Math.max($element.outerWidth(), $element.outerHeight()) * -1
        'opacity': 0.2
      }, 500, ->
        $ripple.trigger 'transitionend'
        return
    return

  ###*
  # Create the jquery plugin function
  ###

  $.fn.ripples = (options) ->
    @each ->
      if !$.data(this, 'plugin_' + ripples)
        $.data this, 'plugin_' + ripples, new Ripples(this, options)
      return

  return
) jQuery, window, document
