ActiveRecord::Schema.define(:version => 0) do
  create_table :posts, :force => true do |t|
    t.column :title, :string
    t.column :body, :text
  end

  create_table :comments, :force => true do |t|
    t.column :post_id, :integer
    t.column :body, :text
  end
  
  create_table :contributions, :force => true do |t|
    t.column :post_id, :integer
    t.column :contributor_id, :integer
    t.column :star, :boolean, :default => false
  end
  
  create_table :contributors, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :profiles, :force => true do |t|
    t.column :contributor_id, :integer
  end
  
  create_table :categories, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :categories_posts, :force => true, :id => false do |t|
    t.column :post_id, :integer
    t.column :category_id, :integer
  end
end