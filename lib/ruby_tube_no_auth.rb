class RubyTubeNoAuth
	attr_accessor :client
	
	def initialize(dev_key="")
		@client = GData::Client::YouTube.new
		@client.source = "RubyTube"
		if dev_key
			@client.developer_key = dev_key
		end
	end
	
	def find(id)
		res = @client.get("http://gdata.youtube.com/feeds/api/videos/#{id}")
		xml = Hpricot.XML(res.body)
		entry = xml.at("entry")
		vid = YTVideo.new({
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
		vid
	end
	
	def comments(id)
		res = @client.get("http://gdata.youtube.com/feeds/api/videos/#{id}/comments")
		xml = Hpricot.XML(res.body)
		comments = Array.new
		if (xml/"entry").nitems > 0
			(xml/"entry").each do |entry|
				cmt = YTComment.new({
					:title => (entry/"title").text,
					:content => (entry/"content").text,
					:author => (entry/"author").search("name").text,
					:author_uri => (entry/"author").search("uri").text,
					:video_uri => (entry/"link[@rel='related']").attr("href")
				})
				comments << cmt
			end
		end
		comments
	end
	
	def ratings(id)
		response = Hpricot.XML(@client.get("http://gdata.youtube.com/feeds/api/videos/#{id}").body)
		ratings = (response/"gd:rating")
		if ratings.nitems > 0
			return ratings
		else
			return nil
		end
	end
	
	private
		def process_thumbnail_urls(hpricot)
			thumbs = (hpricot/"media:thumbnail")
			{:big => thumbs.last["url"], :small => thumbs.first["url"]}
		end
end