class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.text :content
      t.text :q_content
      t.text :answer
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :questions, [:user_id, :created_at]
  end
end
