require File.join(File.dirname(__FILE__), "yt_client.rb")
require File.join(File.dirname(__FILE__), "yt_video.rb")

class RubyTube < YTClient
	
	DEV_KEY = "AI39si6AUy_AzaCEU5TSUFeV7m2RozUtYW-0SEUR2DHh9hltQpZ2LrUYyNwF3R8eyl3VucUxJNCth4s4P2H8X24hyr2Els8uJg"
	
	def initialize(username, password, key, options={:refresh=>300})
		super(username, password, key)
	end
	
	def find(id)
		xml = super.check_video(id)
	end
	
	def find_all
		all = super.all
		
	end
	
	def count
		super.count
	end
	
end