class WeatherController < ApplicationController
	before_action :authenticate_user!

	# Get the weather information based on the address. 
	def weather_info
		@weather_info = { data: {}, error: '', cached: false }
		return @weather_info unless params[:search].present?

		get_data_from_cache
		if @weather_info[:data].empty?
			@weather_info = WeatherService.new(params[:search]).fetch_weather_data
			store_data_in_cache if @weather_info[:data]
		end
	end

	private

	# Store the data in cache for 30 minutes.
	def store_data_in_cache
		Rails.cache&.write(params[:search], @weather_info[:data], expires_in: 30.minutes)
	end

	# Get the data from cache.
	def get_data_from_cache
		data = Rails.cache&.read(params[:search])
		return "" unless data

		@weather_info[:data] = data
		@weather_info[:cached] = true
	end
end