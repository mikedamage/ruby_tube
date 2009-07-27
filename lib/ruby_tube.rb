require File.join(File.dirname(__FILE__), "yt_client.rb")
require File.join(File.dirname(__FILE__), "yt_video.rb")
require File.join(File.dirname(__FILE__), "yt_comment.rb")
require File.join(File.dirname(__FILE__), "yt_rating.rb")
require File.join(File.dirname(__FILE__), "no_auth_client.rb")

class RubyTube < YTClient
	
	def initialize(username, password, key, options={:refresh=>300})
		super(username, password, key, options)
	end
	
	def find(id)
		xml = check_video(id)
		entry = (xml/"entry")
		status = (xml/"yt:state").empty? ? "ok" : (xml/"yt:state").attr("name")
		video = YTVideo.new({
			:id => (entry/"yt:videoid").text,
			:title => (entry/"title").text,
			:description => (entry/"media:description").text,
			:keywords => (entry/"media:keywords").text,
			:duration => (entry/"yt:duration").attr("seconds").to_i,
			:player_uri => (entry/"link[@rel='alternate']").attr("href"),
			:ratings_uri => (entry/"link[@rel$='ratings']").attr("href"),
			:comments_uri => (entry/"gd:comments").search("gd:feedlink").attr("href"),
			:comment_count => (entry/"gd:comments").search("gd:feedlink").attr("countHint").to_i,
			:published_at => Time.parse((entry/"published").text),
			:updated_at => Time.parse((entry/"updated").text),
			:view_count => (entry/"yt:statistics").empty? ? 0 : (entry/"yt:statistics").attr("viewCount"),
			:favorite_count => (entry/"yt:statistics").empty? ? 0 : (entry/"yt:statistics").attr("favoriteCount"),
			:comments => comments((entry/"yt:videoid").text),
			:ratings => ratings((entry/"yt:videoid").text),
			:status => status,
			:thumbnails => process_thumbnail_urls(entry)
		})
		return video
	end
	
	def find_all
		@all = all()
		videos = Array.new
		(all/"entry").each do |entry|
			status = (entry/"yt:state").empty? ? "ok" : (entry/"yt:state").attr("name")
			video = YTVideo.new({
				:id => (entry/"yt:videoid").text,
				:title => (entry/"title").text,
				:description => (entry/"media:description").text,
				:keywords => (entry/"media:keywords").text,
				:duration => (entry/"yt:duration").attr("seconds").to_i,
				:player_uri => (entry/"link[@rel='alternate']").attr("href"),
				:ratings_uri => (entry/"link[@rel$='ratings']").attr("href"),
				:comments_uri => (entry/"gd:comments").search("gd:feedlink").attr("href"),
				:comment_count => (entry/"gd:comments").search("gd:feedlink").attr("countHint").to_i,
				:published_at => Time.parse((entry/"published").text),
				:updated_at => Time.parse((entry/"updated").text),
				:view_count => (entry/"yt:statistics").empty? ? 0 : (entry/"yt:statistics").attr("viewCount"),
				:favorite_count => (entry/"yt:statistics").empty? ? 0 : (entry/"yt:statistics").attr("favoriteCount"),
				:comments => comments((entry/"yt:videoid").text),
				:ratings => ratings((entry/"yt:videoid").text),
				:status => status,
				:thumbnails => process_thumbnail_urls(entry)
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
	
	def update_video(id, options)
		video = find(id)
		if options[:title]
			video.title = options[:title]
		end
		if options[:description]
			video.description = options[:description]
		end
		if options[:keywords]
			video.keywords = options[:keywords]
		end
		entry = video.to_xml
		response = update(video.id, entry)
		if response.status_code == 200
			return video
		else
			return false
		end
	end
	
	def upload_video(filename, options={})
		response = upload(filename, options)
	end
	
	def delete_video(id)
		response = delete(id)
		if response.status_code == 200
			return true
		else
			return false
		end
	end
	
	private
		def process_thumbnail_urls(hpricot)
			thumbs = (hpricot/"media:thumbnail")
			{:big => thumbs.last["url"], :small => thumbs.first["url"]}
		end
	
end