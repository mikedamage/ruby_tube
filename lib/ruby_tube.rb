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
		videos = Array.new
		(all/"entry").each do |entry|
			video = YTVideo.new({
				:id => (entry/"yt:videoid").text,
				:title => (entry/"title").text,
				:description => (entry/"media:description").text,
				:duration => (entry/"yt:duration").attr("seconds").to_i,
				:player_uri => (entry/"link[@rel='alternate']").attr("href"),
				:ratings_uri => (entry/"link[@rel$='ratings']").attr("href"),
				:comments_uri => (entry/"gd:comments").search("gd:feedlink").attr("href"),
				:comment_count => (entry/"gd:comments").search("gd:feedlink").attr("countHint").to_i,
				:published_at => Time.parse((entry/"published").text),
				:updated_at => Time.parse((entry/"updated").text),
				:thumbnails => {
					:small => {
						:url => (entry/"media:thumbnail[@url$='default.jpg']").attr("url"),
						:width => 120,
						:height => 90
					},
					:large => {
						:url => (entry/"media:thumbnail[@url$='hqdefault.jpg]").attr("url"),
						:width => 480,
						:height => 360
					}
				},
				:view_count => (entry/"yt:statistics").attr("viewCount"),
				:favorite_count => (entry/"yt:statistics").attr("favoriteCount")
			})
		end
	end
	
	def count
		super.count
	end
	
end