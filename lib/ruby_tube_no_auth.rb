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
			:id => entry.at("yt:videoid").inner_text,
			:title => entry.at("media:title").inner_text,
			:description => entry.at("media:description").inner_text,
			:keywords => entry.at("media:keywords").inner_text,
			:duration => entry.at("yt:duration")["seconds"].to_i,
			:player_uri => entry.at("link[@rel='alternate']")["href"],
			:ratings_uri => entry.at("link[@rel$='ratings']")["href"],
			:comments_uri => entry.at("gd:comments").at("gd:feedLink")["href"],
			:comment_count => entry.at("gd:comments").at("gd:feedLink")["countHint"].to_i,
			:published_at => Time.parse(entry.at("published").inner_text),
			:updated_at => Time.parse(entry.at("updated").inner_text),
			:view_count => entry.at("yt:statistics").nil? ? 0 : entry.at("yt:statistics")["viewCount"].to_i,
			:favorite_count => entry.at("yt:statistics").nil? ? 0 : entry.at("yt:statistics")["favoriteCount"].to_i,
			:comments => comments(entry.at("yt:videoid").inner_text),
			:ratings => ratings(entry),
			:status => status(entry),
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
	
	private
		def process_thumbnail_urls(hpricot)
			thumbs = (hpricot/"media:thumbnail")
			{:big => thumbs.last["url"], :small => thumbs.first["url"]}
		end
		
		def ratings(hpricot)
			rating_info = hpricot.at("gd:rating")
			{
				:max => rating_info['max'].to_i,
				:min => rating_info['min'].to_i,
				:average => rating_info['average'].to_f,
				:num_raters => rating_info['numRaters'].to_i
			}
		end
		
		def status(hpricot)
			hpricot.at("yt:duration").nil? ? "processing" : "live"
		end
end