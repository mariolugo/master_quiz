### globals jQuery ###

(($) ->
  # Selector to select only not already processed elements

  _isChar = (evt) ->
    if typeof evt.which == 'undefined'
      return true
    else if typeof evt.which == 'number' and evt.which > 0
      return !evt.ctrlKey and !evt.metaKey and !evt.altKey and evt.which != 8 and evt.which != 9 and evt.which != 13 and evt.which != 16 and evt.which != 17 and evt.which != 20 and evt.which != 27
    false

  _addFormGroupFocus = (element) ->
    $element = $(element)
    if !$element.prop('disabled')
      # this is showing as undefined on chrome but works fine on firefox??
      $element.closest('.form-group').addClass 'is-focused'
    return

  _toggleDisabledState = ($element, state) ->
    $target = undefined
    if $element.hasClass('checkbox-inline') or $element.hasClass('radio-inline')
      $target = $element
    else
      $target = if $element.closest('.checkbox').length then $element.closest('.checkbox') else $element.closest('.radio')
    $target.toggleClass 'disabled', state

  _toggleTypeFocus = ($input) ->
    disabledToggleType = false
    if $input.is($.material.options.checkboxElements) or $input.is($.material.options.radioElements)
      disabledToggleType = true
    $input.closest('label').hover (->
      $i = $(this).find('input')
      isDisabled = $i.prop('disabled')
      # hack because the _addFormGroupFocus() wasn't identifying the property on chrome
      if disabledToggleType
        _toggleDisabledState $(this), isDisabled
      if !isDisabled
        _addFormGroupFocus $i
        # need to find the input so we can check disablement
      return
    ), ->
      _removeFormGroupFocus $(this).find('input')
      return
    return

  _removeFormGroupFocus = (element) ->
    $(element).closest('.form-group').removeClass 'is-focused'
    # remove class from form-group
    return

  $.expr[':'].notmdproc = (obj) ->
    if $(obj).data('mdproc')
      false
    else
      true

  $.material =
    'options':
      'validate': true
      'input': true
      'ripples': true
      'checkbox': true
      'togglebutton': true
      'radio': true
      'arrive': true
      'autofill': false
      'withRipples': [
        '.btn:not(.btn-link)'
        '.card-image'
        '.navbar a:not(.withoutripple)'
        '.dropdown-menu a'
        '.nav-tabs a:not(.withoutripple)'
        '.withripple'
        '.pagination li:not(.active):not(.disabled) a:not(.withoutripple)'
      ].join(',')
      'inputElements': 'input.form-control, textarea.form-control, select.form-control'
      'checkboxElements': '.checkbox > label > input[type=checkbox], label.checkbox-inline > input[type=checkbox]'
      'togglebuttonElements': '.togglebutton > label > input[type=checkbox]'
      'radioElements': '.radio > label > input[type=radio], label.radio-inline > input[type=radio]'
    'checkbox': (selector) ->
      # Add fake-checkbox to material checkboxes
      $input = $(if selector then selector else @options.checkboxElements).filter(':notmdproc').data('mdproc', true).after('<span class=\'checkbox-material\'><span class=\'check\'></span></span>')
      _toggleTypeFocus $input
      return
    'togglebutton': (selector) ->
      # Add fake-checkbox to material checkboxes
      $input = $(if selector then selector else @options.togglebuttonElements).filter(':notmdproc').data('mdproc', true).after('<span class=\'toggle\'></span>')
      _toggleTypeFocus $input
      return
    'radio': (selector) ->
      # Add fake-radio to material radios
      $input = $(if selector then selector else @options.radioElements).filter(':notmdproc').data('mdproc', true).after('<span class=\'circle\'></span><span class=\'check\'></span>')
      _toggleTypeFocus $input
      return
    'input': (selector) ->
      $(if selector then selector else @options.inputElements).filter(':notmdproc').data('mdproc', true).each ->
        $input = $(this)
        # Requires form-group standard markup (will add it if necessary)
        $formGroup = $input.closest('.form-group')
        # note that form-group may be grandparent in the case of an input-group
        if $formGroup.length == 0 and $input.attr('type') != 'hidden' and !$input.attr('hidden')
          $input.wrap '<div class=\'form-group\'></div>'
          $formGroup = $input.closest('.form-group')
          # find node after attached (otherwise additional attachments don't work)
        # Legacy - Add hint label if using the old shorthand data-hint attribute on the input
        if $input.attr('data-hint')
          $input.after '<p class=\'help-block\'>' + $input.attr('data-hint') + '</p>'
          $input.removeAttr 'data-hint'
        # Legacy - Change input-sm/lg to form-group-sm/lg instead (preferred standard and simpler css/less variants)
        legacySizes = 
          'input-lg': 'form-group-lg'
          'input-sm': 'form-group-sm'
        $.each legacySizes, (legacySize, standardSize) ->
          if $input.hasClass(legacySize)
            $input.removeClass legacySize
            $formGroup.addClass standardSize
          return
        # Legacy - Add label-floating if using old shorthand <input class="floating-label" placeholder="foo">
        if $input.hasClass('floating-label')
          placeholder = $input.attr('placeholder')
          $input.attr('placeholder', null).removeClass 'floating-label'
          id = $input.attr('id')
          forAttribute = ''
          if id
            forAttribute = 'for=\'' + id + '\''
          $formGroup.addClass 'label-floating'
          $input.after '<label ' + forAttribute + 'class=\'control-label\'>' + placeholder + '</label>'
        # Set as empty if is empty (damn I must improve this...)
        if $input.val() == null or $input.val() == 'undefined' or $input.val() == ''
          $formGroup.addClass 'is-empty'
        # Support for file input
        if $formGroup.find('input[type=file]').length > 0
          $formGroup.addClass 'is-fileinput'
        return
      return
    'attachInputEventHandlers': ->
      validate = @options.validate
      $(document).on('keydown paste', '.form-control', (e) ->
        if _isChar(e)
          $(this).closest('.form-group').removeClass 'is-empty'
        return
      ).on('keyup change', '.form-control', ->
        $input = $(this)
        $formGroup = $input.closest('.form-group')
        isValid = typeof $input[0].checkValidity == 'undefined' or $input[0].checkValidity()
        if $input.val() == ''
          $formGroup.addClass 'is-empty'
        else
          $formGroup.removeClass 'is-empty'
        # Validation events do not bubble, so they must be attached directly to the input: http://jsfiddle.net/PEpRM/1/
        #  Further, even the bind method is being caught, but since we are already calling #checkValidity here, just alter
        #  the form-group on change.
        #
        # NOTE: I'm not sure we should be intervening regarding validation, this seems better as a README and snippet of code.
        #        BUT, I've left it here for backwards compatibility.
        if validate
          if isValid
            $formGroup.removeClass 'has-error'
          else
            $formGroup.addClass 'has-error'
        return
      ).on('focus', '.form-control, .form-group.is-fileinput', ->
        _addFormGroupFocus this
        return
      ).on('blur', '.form-control, .form-group.is-fileinput', ->
        _removeFormGroupFocus this
        return
      ).on('change', '.form-group input', ->
        $input = $(this)
        if $input.attr('type') == 'file'
          return
        $formGroup = $input.closest('.form-group')
        value = $input.val()
        if value
          $formGroup.removeClass 'is-empty'
        else
          $formGroup.addClass 'is-empty'
        return
      ).on 'change', '.form-group.is-fileinput input[type=\'file\']', ->
        $input = $(this)
        $formGroup = $input.closest('.form-group')
        value = ''
        $.each @files, (i, file) ->
          value += file.name + ', '
          return
        value = value.substring(0, value.length - 2)
        if value
          $formGroup.removeClass 'is-empty'
        else
          $formGroup.addClass 'is-empty'
        $formGroup.find('input.form-control[readonly]').val value
        return
      return
    'ripples': (selector) ->
      $(if selector then selector else @options.withRipples).ripples()
      return
    'autofill': ->
      # This part of code will detect autofill when the page is loading (username and password inputs for example)
      loading = setInterval((->
        $('input[type!=checkbox]').each ->
          $this = $(this)
          if $this.val() and $this.val() != $this.attr('value')
            $this.trigger 'change'
          return
        return
      ), 100)
      # After 10 seconds we are quite sure all the needed inputs are autofilled then we can stop checking them
      setTimeout (->
        clearInterval loading
        return
      ), 10000
      return
    'attachAutofillEventHandlers': ->
      # Listen on inputs of the focused form (because user can select from the autofill dropdown only when the input has focus)
      focused = undefined
      $(document).on('focus', 'input', ->
        $inputs = $(this).parents('form').find('input').not('[type=file]')
        focused = setInterval((->
          $inputs.each ->
            $this = $(this)
            if $this.val() != $this.attr('value')
              $this.trigger 'change'
            return
          return
        ), 100)
        return
      ).on 'blur', '.form-group input', ->
        clearInterval focused
        return
      return
    'init': (options) ->
      @options = $.extend({}, @options, options)
      $document = $(document)
      if $.fn.ripples and @options.ripples
        @ripples()
      if @options.input
        @input()
        @attachInputEventHandlers()
      if @options.checkbox
        @checkbox()
      if @options.togglebutton
        @togglebutton()
      if @options.radio
        @radio()
      if @options.autofill
        @autofill()
        @attachAutofillEventHandlers()
      if document.arrive and @options.arrive
        if $.fn.ripples and @options.ripples
          $document.arrive @options.withRipples, ->
            $.material.ripples $(this)
            return
        if @options.input
          $document.arrive @options.inputElements, ->
            $.material.input $(this)
            return
        if @options.checkbox
          $document.arrive @options.checkboxElements, ->
            $.material.checkbox $(this)
            return
        if @options.radio
          $document.arrive @options.radioElements, ->
            $.material.radio $(this)
            return
        if @options.togglebutton
          $document.arrive @options.togglebuttonElements, ->
            $.material.togglebutton $(this)
            return
      return
  return
) jQuery
