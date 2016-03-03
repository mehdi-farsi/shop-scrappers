class Subsection < ActiveRecord::Base
  has_many   :products

  belongs_to :section
end
