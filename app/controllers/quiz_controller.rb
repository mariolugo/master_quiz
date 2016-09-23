class QuizController < ApplicationController
    def index
    session[:counter] = 1 # initilize question counter 
    session[:questions_ids] = Question.questions_ids  # initilize quiz question ids 
    quiz_questions_ids = session[:questions_ids]  
    session[:quiz_length] = quiz_questions_ids.length # initialize quiz length
    session[:grading] = 0 # initialize grading 
    session[:graded_answers] = 0 # initialize graded answers (for quiz persistance when refreshing page)
  end

  def quiz
    # initialize
    if session[:questions_ids] != nil 
      @counter = session[:counter]
       # if the user tries to cheat refreshing the page, redirect to home.
      if session[:graded_answers] == @counter
        redirect_to '/'
      end
      @quiz_length = session[:quiz_length]
      quiz_questions_ids = session[:questions_ids]
      @question = Question.find(quiz_questions_ids[@counter-1]) #get the question to display
    else
      # variables are not initialized then redirect to index
      redirect_to '/' 
    end
  end

  def check_answer
    session[:graded_answers] = session[:graded_answers].to_i + 1 #format to pass the rspec test 
    answer = params[:ans].strip.downcase
    question_id = params[:qs_id]
    result = Question.qualify(question_id, answer)
    session[:grading] = session[:grading].to_i + 1 unless result == false #format to pass the rspec test
    render json: {result: result}
  end

  # get the next question in the quiz
  def next_question
    quiz_length = session[:quiz_length]
    session[:counter] += 1
    counter = session[:counter]
    if counter > 10
      render json: {result: true} #send true when the last question is reached
    else
      quiz_questions_ids = session[:questions_ids]
      next_question = Question.find(quiz_questions_ids[session[:counter]-1]) # gets the next question from the array with question ids
      render json: {content: next_question.content, id: next_question.id, counter: counter, length: quiz_length}
    end
  end

  # display the final result 
  def result
    @correct = session[:grading]
    @incorrect = 10 - session[:grading].to_i
    session.clear
  end

end
