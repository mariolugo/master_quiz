class Question < ApplicationRecord
    belongs_to :user
    validates :user_id, presence: true
    validates :content, presence: true, length: { maximum: 300 }

    #method to grade if the submitted andswer is correct
    def self.qualify(question_id, submitted_answer)
        answer = Question.find(question_id).answer.downcase.strip
        # if the answer of the question contains only numbers => convert it to string
        if answer.scan(/\D+/).empty? == true
        answer = answer.to_i.in_words
        end
        if answer == submitted_answer || answer == submitted_answer.to_i.in_words #is correct? 
        return true # The answer is correct!
        else
        return false
        end
    end

    # create the 10 questions of the quiz and return the ids
    def self.questions_ids
        questions_id = []
        Question.all.sample(10).each do |q|
        questions_id << q.id
        end
        questions_id
    end
end
