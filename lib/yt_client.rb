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
				@all_vids = Hpricot(@client.get(self.class.base_uri + "/users/default/uploads").body)
			else
				return @all_vids
			end
		else
			@all_vids = Hpricot(@client.get(self.class.base_uri + "/users/default/uploads").body)
		end
	end
	
	def count
		(@all_vids/"entry").nitems
	end
	
	def check_video(id)
		Hpricot(@client.get(self.class.base_uri + "/videos/#{id}").body)
	end
	
	def ratings(id)
		Hpricot(@client.get(self.class.base_uri + "/videos/#{id}/ratings").body)
	end
	
	def comments(id)
		Hpricot(@client.get(self.class.base_uri + "/videos/#{id}/comments").body)
	end
	
	def upload(file, options={})
		upload_uri = URI.parse(UPLOAD_URI)
		binary_data = read_file(file)
		request_data = <<-REQDATA
--bbe873dc
Content-Type: application/atom+xml; charset=utf-8

<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom"
	xmlns:media="http://search.yahoo.com/mrss/"
	xmlns:yt="http://gdata.youtube.com/schemas/2007">
	<media:group>
		<media:title type="plain">#{options[:title]}</media:title>
		<media:description type="plain">
			#{options[:description]}
		</media:description>
		<media:category scheme="http://gdata.youtube.com/schemas/2007/categories.cat">
			People
		</media:category>
		<media:keywords>#{options[:keywords]}</media:keywords>
	</media:group>
</entry>
--bbe873dc
Content-Type: #{options[:content_type]}
Content-Transfer-Encoding: binary

#{binary_data}
--bbe873dc
REQDATA
		http = Net::HTTP.new(upload_uri.host)
		headers = {
			'GData-Version' => "2",
			'X-GData-Key' => "key=#{DEV_KEY}",
			'Slug' => File.basename(file),
			'Authorization' => "GoogleLogin auth=#{@token}",
			'Content-Type' => 'multipart/related; boundary="bbe873dc"',
			'Content-Length' => binary_data.length.to_s,
			'Connection' => 'close'
		}
		res = http.post(upload_uri.path, request_data, headers)
		response = {:code => res.code, :body => Hpricot(res.body)}
		return response
	end
	
	private
	def read_file(file)
		contents = File.open(file, "r") {|io| io.read }
		return contents
	end
end