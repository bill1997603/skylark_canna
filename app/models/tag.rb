class Tag < ApplicationRecord
  has_and_belongs_to_many :problems

  validates :description, presence: true, uniqueness: true, length: { maximum: 10 }
end
