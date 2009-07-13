require "rubygems"
require "hpricot"
require "httparty"

class YTVideo
	include HTTParty
	attr_reader :id, :title, :description, :duration, :player_uri, :thumbnails, :published_at, :updated_at, :ratings_uri, :comments_uri, :view_count, :favorite_count, :comment_count
	
	format :plain
	
	def initialize(data)
		@id = data[:id]
		@title = data[:title]
		@description = data[:description]
		@duration = data[:duration]
		@player_uri = data[:player_uri]
		@ratings_uri = data[:ratings_uri]
		@comments_uri = data[:comments_uri]
		@published_at = data[:published_at]
		@updated_at = data[:updated_at]
		@thumbnails = data[:thumbnails]
		@view_count = data[:view_count]
		@favorite_count = data[:favorite_count]
		@comment_count = data[:comment_count]
	end
	
end