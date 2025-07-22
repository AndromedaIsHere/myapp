class Sketch < ApplicationRecord
  belongs_to :user, optional: true # (optional: true for the first migration)
  has_one_attached :image
end
