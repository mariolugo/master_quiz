# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

###
# Welcome to the new js2coffee 2.0, now
# rewritten to use the esprima parser.
# try it out!
###

$(document).ready ->
  quiz_length = parseInt($('#quiz_length').text())
  counter = 1
  correct = 0
  # check answer when is submitted
  # end of function
  # function to check if the answer is correct (post) and make changes accordingly 

  checkAnswer = ->
    $('#showResult').modal 'show'
    answer = $('#input-answer-text').val()
    question_id = $('.question-display').attr('id')
    $.post '/quiz/check', {
      qs_id: question_id
      ans: answer
    }, (data) ->
      console.log data
      if counter == quiz_length
        $('#submit-answer-button').html 'Finish Quiz'
        $('#next-question-button').html 'Show Results!'
      else
      if data.result == true
        correct++
        $('.modal-title').html 'Congratulations!'
        $('.modal-title').css 'color', '#5cb85c'
        $('.graded-answer').html 'Your answer was right!'
      else
        $('#try-again-button').prop 'disabled', false
        $('.modal-title').html 'Ups.. wrong answer!'
        $('.graded-answer').html 'Your answer was incorrect ;(!'
        $('.modal-title').css 'color', '#d9534f'
      $('.your-answer-label').html 'Your answer: ' + answer
      return
    #end of post
    return

  # end of function
  # Function to dismplay the next question content

  nextQuestion = ->
    console.log counter
    console.log quiz_length
    $.post '/quiz/next', (data) ->
      counter = data.counter
      if counter == quiz_length
        $('#next-question-button').html 'Show Results!'
      else
      if data.result == true
        window.location.href = '/quiz/result'
      else
        content = data.content
        id = data.id
        $('.question-display').attr 'id', id
        $('.question-display').html content
        $('#submit-answer-button').prop 'disabled', false
        $('#input-answer-text').val ''
        $('.question-counter').html 'Question ' + data.counter + ' of ' + data.length
      return
    # end of post    
    return

  finishQuiz = ->
    console.log counter
    console.log quiz_length
    console.log correct
    result = correct/quiz_length
    if result != 0
        result = result * 100
        result = result.toFixed(2)
    $('.modal-title').html 'Quiz results!'
    $('.total-answers').html 'Total questions '+quiz_length
    $('.total-correct').html 'Correct questions '+correct
    $('.quiz-grade').text 'Your final grade is: '+ result
    $('#next-question-button').html 'Finish!'
    

  $('form#submit-answer-form').submit (e) ->
    e.preventDefault()
    checkAnswer()
    return
  # end of function
  # function with a post petition to change the question
  $('#next-question-button').click ->
    if counter == quiz_length
        console.log 'se acabo'
        finishQuiz()
        $('#showResult').modal 'hide'
        $('#finalResult').modal 'show'
    else
        nextQuestion()
        $('#showResult').modal 'hide'
    return
    
    return
  # end of function
  return
#end of document.ready