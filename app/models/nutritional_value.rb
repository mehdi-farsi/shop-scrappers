class NutritionalValue < ActiveRecord::Base
  has_many :energy_value,    dependent: :destroy
  has_many :nutrition_types, dependent: :destroy

  belongs_to :product
end
