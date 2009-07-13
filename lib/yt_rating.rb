class YTRating
	attr_accessor :num_raters, :min, :max, :average
	
	def initialize(data)
		@num_raters = data[:num_raters].to_i
		@min = data[:min].to_i
		@max = data[:max].to_i
		@average = data[:average].to_f
	end
end