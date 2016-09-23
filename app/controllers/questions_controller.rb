class QuestionsController < ApplicationController

  #shows all the questions
  def index
    @questions = Question.paginate(page: params[:page])
  end

  #shows a question
  def show
    @question = Question.find(params[:id])
  end

  #new question view
  def new
    @question = Question.new
  end

  #edit question view
  def edit
    @question = Question.find(params[:id])
  end

  #method to create a question
  def create
    @question = current_user.questions.build(question_params)
    @question.q_content = @question.content
    if @question.save
      flash[:success] = "Question created!"
      redirect_to questions_path
    else
      render 'new'
    end
  end

  #method to update a question
  def update
    @question = Question.find(params[:id])    

    if @question.update(question_params)
      flash[:success] = "Question updated!"
      redirect_to questions_path
    else
      render 'edit'
    end
  end

  #method to delete a question 
  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    flash[:danger] = "Question deleted!"
    redirect_to questions_path
  end

  private

  def question_params
    params.require(:question).permit(:content, :answer)
  end
end
