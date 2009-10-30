require "uri"
require "net/http"
require "gdata"
require "hpricot"
require "httparty"
require "time"

class YTClient
	attr_accessor :username, :password, :developer_key, :token, :client
	include HTTParty
	
	base_uri "http://gdata.youtube.com/feeds/api"
	format :plain
	
	UPLOAD_URI = "http://uploads.gdata.youtube.com/feeds/api/users/default/uploads"
	
	def initialize(username, password, key, options={:refresh=>300})
		@username = username
		@password = password
		@developer_key = key
		@client = GData::Client::YouTube.new
		@client.source = "acer_timeline_contest"
		@client.developer_key = @developer_key
		@token = @client.clientlogin(@username, @password)
		@options = options
	end
	
	def all
		if @all_vids
			if Time.parse((@all_vids/"updated").text) < (Time.now - @options[:refresh])
				@all_vids = Hpricot.XML(@client.get(self.class.base_uri + "/users/default/uploads").body)
			else
				return @all_vids
			end
		else
			@all_vids = Hpricot.XML(@client.get(self.class.base_uri + "/users/default/uploads").body)
		end
	end
	
	def count
		(@all_vids/"entry").nitems
	end
	
	def check_video(id)
		Hpricot.XML(@client.get(self.class.base_uri + "/videos/#{id}").body)
	end
	
	def ratings(id)
		response = Hpricot.XML(@client.get(self.class.base_uri + "/videos/#{id}").body)
		ratings = (response/"gd:rating")
		if ratings.nitems > 0
			return ratings
		else
			return nil
		end
	end
	
	def comments(id)
		Hpricot.XML(@client.get(self.class.base_uri + "/videos/#{id}/comments").body)
	end
	
	def upload(file, options={})
		upload_uri = URI.parse(UPLOAD_URI)
		binary_data = read_file(file)
		keywords = normalize_keywords(options[:keywords])
		entry_xml = %{<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom"
	xmlns:media="http://search.yahoo.com/mrss/"
	xmlns:yt="http://gdata.youtube.com/schemas/2007">
	<media:group>
		<media:title type="plain">#{options[:title]}</media:title>
		<media:description type="plain">
			#{options[:description]}
		</media:description>
		<media:category scheme="http://gdata.youtube.com/schemas/2007/categories.cat">People</media:category>
		<media:keywords>#{keywords}</media:keywords>
	</media:group>
</entry>
		}
		request_data = %{--bbe873dc\r
Content-Type: application/atom+xml; charset=UTF-8

#{entry_xml}\r
--bbe873dc\r
Content-Type: #{options[:content_type]}
Content-Transfer-Encoding: binary

#{binary_data}\r
--bbe873dc--\r\n}
		http = Net::HTTP.new(upload_uri.host)
		http.read_timeout = 6000
		headers = {
			'GData-Version' => "2",
			'X-GData-Key' => "key=#{@developer_key}",
			'Slug' => File.basename(file),
			'Authorization' => "GoogleLogin auth=#{@token}",
			'Content-Type' => 'multipart/related; boundary="bbe873dc"',
			'Content-Length' => request_data.length.to_s,
			'Connection' => 'close'
		}
		res = http.post(upload_uri.path, request_data, headers)
		response = {:code => res.code, :body => Hpricot.XML(res.body)}
		return response
	end
	
	def get_upload_token(options={})
		post_uri = URI.parse("http://gdata.youtube.com/action/GetUploadToken")
		keywords = normalize_keywords(options[:keywords])
		entry_xml = %{
<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom"
	xmlns:media="http://search.yahoo.com/mrss/"
	xmlns:yt="http://gdata.youtube.com/schemas/2007">
	<media:group>
		<media:title type="plain">#{options[:title]}</media:title>
		<media:description type="plain">
			#{options[:description]}
		</media:description>
		<media:category scheme="http://gdata.youtube.com/schemas/2007/categories.cat">People</media:category>
		<media:keywords>#{keywords}</media:keywords>
	</media:group>
</entry>
		}
		http = Net::HTTP.new(post_uri.host)
		http.read_timeout = 20
		headers = {
			'Authorization' => "GoogleLogin auth=#{@token}",
			'GData-Version' => '2',
			'X-GData-Key' => "key=#{@developer_key}",
			'Content-Type' => "application/atom+xml; charset=UTF-8",
			'Content-Length' => entry.xml.length
		}
		post = http.post(post_uri.path, entry_xml, headers)
		response = {:code => post.code, :body => Hpricot.XML(post.body)}
		return response
	end
	
	def update(id, xml)
		response = @client.put(self.class.base_uri + "/users/default/uploads/#{id}", xml)
	end
	
	def delete(id)
		response = @client.delete(self.class.base_uri + "/users/default/uploads/#{id}")
	end
	
	private
	def read_file(file)
		contents = File.open(file, "r") {|io| io.read }
		return contents
	end
	
	def normalize_keywords(str)
		keywords = str.split(",")
		keywords.map! {|kw| kw.strip }
		return keywords.join(', ')
	end
end