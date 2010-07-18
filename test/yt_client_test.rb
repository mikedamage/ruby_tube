require "test_helper"


class YTClientTest < Test::Unit::TestCase
	context "A YTClient instance" do
		setup do
			@yt = YTClient.new("username", "password", RubyTube::DEV_KEY) # Add real auth credentials here to test
		end
		
		should "retrieve a ClientLogin token on instantiation" do
			assert not_nil(@yt.token)
		end
		
		should "return a list of uploaded files" do
			assert not_nil(@yt.all)
		end
		
		should "return Fixnum when #count is called" do
			assert @yt.count.is_a?(Fixnum)
		end
		
		# TODO: write upload tests w/o having to repeat the upload process for each test
	end
	
	private
	def not_nil(item)
		!item.nil?
	end
	
	def not_empty(item)
		!item.empty?
	end
end