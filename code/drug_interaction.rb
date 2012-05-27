class DrugInteraction < ActiveRecord::Base
	include Spira::Resource
	base_uri "http://osmanov.me/drug_interactions/"
	type URI.new("http://osmanov.me/drug_interactions")

	property :drug, 
		:predicate => URI.new("http://osmanov.me/interaction_with"), 
		:type => :Drug
	property :description, 
		:predicate => URI.new("http://osmanov.me/description"), 
		:type => String

end