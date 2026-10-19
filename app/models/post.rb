class Post < ApplicationRecord
  belongs_to :user
  belongs_to :club
  belongs_to :tag
  has_many :comments, dependent: :destroy

  validates :rating, inclusion: { in: 1..5 }
  validates :body, presence: true
end
