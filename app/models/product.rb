class Product < ActiveRecord::Base
  has_one   :ingredient,        dependent: :destroy
  has_one   :nutritional_value, dependent: :destroy

  belongs_to :subsection
end
