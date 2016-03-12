class Ingredient < ActiveRecord::Base
  has_many   :ingredient_types, dependent: :destroy

  belongs_to :product
end
