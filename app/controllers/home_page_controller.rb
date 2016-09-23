class HomePageController < ApplicationController
  def home
    if logged_in?
      session[:counter] = 1 # initilize question counter 
      session[:questions_ids] = Question.questions_ids  # initilize quiz question ids 
      quiz_questions_ids = session[:questions_ids]  
      session[:quiz_length] = quiz_questions_ids.length # initialize quiz length
      session[:grading] = 0 # initialize grading 
      session[:graded_answers] = 0 # initialize graded answers (for quiz persistance when refreshing page)
    end
    @user = current_user
    @questions = Question.count()
  end

  def help
  end
end
