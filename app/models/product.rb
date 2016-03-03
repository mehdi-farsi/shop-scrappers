class Product < ActiveRecord::Base
  has_many   :ingredients,        dependent: :destroy
  has_many   :nutritional_values, dependent: :destroy

  belongs_to :subsection
end
