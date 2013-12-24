class Material < ActiveRecord::Base
  belongs_to :organism
  has_many :msresults
  has_many :materialweights
end
