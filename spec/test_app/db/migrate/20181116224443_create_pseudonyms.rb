class CreatePseudonyms < ActiveRecord::Migration[5.0]
  def change
    create_table :pseudonyms do |t|
      t.string :sis_user_id
      t.integer :user_id
    end
  end
end
