require 'test_helper'

class RubyTubeTest < Test::Unit::TestCase
  context "a RubyTube instance" do
		setup do
			@yt = RubyTube.new
		end
		
		should "contain an instance of GData::Client::YouTube" do
			assert @yt.client.is_a?(GData::Client::YouTube)
		end
		
		should "get a ClientLogin token from YouTube" do
			assert @yt.token
		end
	end
end
