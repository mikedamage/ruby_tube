class YTComment
	
	attr_accessor :title, :content, :author, :author_uri, :video_uri
	
	def initialize(data)
		@title = data[:title]
		@content = data[:content]
		@author = data[:author]
		@author_uri = data[:author_uri]
		@video_uri = data[:video_uri]
	end
	
end