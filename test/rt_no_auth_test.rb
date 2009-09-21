class RTNoAuthTest < Test::Unit::TestCase
	context "A RubyTubeNoAuth instance" do
		setup do
			@dev_key = "AI39si6AUy_AzaCEU5TSUFeV7m2RozUtYW-0SEUR2DHh9hltQpZ2LrUYyNwF3R8eyl3VucUxJNCth4s4P2H8X24hyr2Els8uJg"
			@test_vid_id = "5YNOZksBoDc"
			@ruby_tube = RubyTubeNoAuth.new(DEV_KEY)
		end
		
		should "return a new instance of RubyTubeNoAuth" do
			assert not_nil(@ruby_tube) && @ruby_tube.is_a?(RubyTubeNoAuth)
		end
		
		should "return an instance of YTVideo on calling #find(id)" do
			vid = @ruby_tube.find(@test_vid_id)
			assert vid.is_a?(YTVideo)
		end
	end
	
	private
	def not_nil(obj)
		!obj.nil?
	end
	
	def not_empty(obj)
		!obj.empty?
	end
end