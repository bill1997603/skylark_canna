class Option < ApplicationRecord
  belongs_to :problem, optional: true

  validates :description, presence: true
end
