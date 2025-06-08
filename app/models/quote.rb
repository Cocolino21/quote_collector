class Quote < ApplicationRecord
    validates :content, presence: true
    validates :author, presence: true
    validates :category, presence: true
    
    scope :by_author, ->(author) { where("author LIKE ?", "%#{author}%") }
    scope :by_category, ->(category) { where("category LIKE ?", "%#{category}%") }
    scope :search, ->(term) { where("content LIKE ? OR author LIKE ?", "%#{term}%", "%#{term}%") }
    
    def self.random_quote
      offset(rand(count)).first
    end
  end