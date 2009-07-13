require File.join(File.dirname(__FILE__), "yt_client.rb")
require File.join(File.dirname(__FILE__), "yt_video.rb")
require File.join(File.dirname(__FILE__), "yt_comment.rb")
require File.join(File.dirname(__FILE__), "yt_rating.rb")

class RubyTube < YTClient
	
	# DEV_KEY = "AI39si6AUy_AzaCEU5TSUFeV7m2RozUtYW-0SEUR2DHh9hltQpZ2LrUYyNwF3R8eyl3VucUxJNCth4s4P2H8X24hyr2Els8uJg"
	# 	USERNAME = "frcmike"
	# 	PASSWORD = "k2130k"
	
	def initialize(username, password, key, options={:refresh=>300})
	#def initialize
		super(username, password, key, options)
	end
	
	def find(id)
		xml = check_video(id)
		entry = (xml/"entry")
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
			:favorite_count => (entry/"yt:statistics").attr("favoriteCount"),
			:comments => comments((entry/"yt:videoid").text),
			:ratings => nil
		})
		return video
	end
	
	def find_all
		@all = all()
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
				:favorite_count => (entry/"yt:statistics").attr("favoriteCount"),
				:comments => comments((entry/"yt:videoid").text),
				:ratings => ratings((entry/"yt:videoid").text)
			})
			videos << video
		end
		return videos
	end
	
	def count
		super
	end
	
	def comments(id)
		xml = super
		comments = Array.new
		if (xml/"entry").nitems > 0
			(xml/"entry").each do |entry|
				comment = YTComment.new({
					:title => (entry/"title").text,
					:content => (entry/"content").text,
					:author => (entry/"author").search("name").text,
					:author_uri => (entry/"author").search("uri").text,
					:video_uri => (entry/"link[@rel='related']").attr("href")
				})
				comments << comment
			end
		end
		return comments
	end
	
	def ratings(id)
		xml = super
		rating = nil
		if xml
			rating = YTRating.new({
				:num_raters => xml.attr("numRaters").to_i,
				:max => xml.attr("max").to_i,
				:min => xml.attr("min").to_i,
				:average => xml.attr("average").to_f
			})
		end
		return rating
	end
	
end