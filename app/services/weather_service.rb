class WeatherService
	def initialize(place_or_zip)
		@search_key = place_or_zip
		@lat = @lon = @errors = @report = ""
	end

	# fetch weather report data.
	def fetch_weather_data
		begin
			return { error: "Please enter valid Place name or ZipCode" } unless fetch_lat_lon.present?
			fetch_weather_by_lat_lon
		rescue Exception => e
			return { error: e }
		end
	end

	private

	# Fetch lattitude and longitude.
	def fetch_lat_lon
		return "" unless ENV['OPEN_WEATHER_SECRET_KEY']

		if @search_key.to_i != 0
			fetch_by_zipcode if ENV['OPEN_WEATHER_GEO_ZIP_ENDPOINT']
		else
			fetch_by_place_name if ENV['OPEN_WEATHER_GEO_ENDPOINT']
		end
	end

	# Get weather report data by passing zipcode.
	def fetch_by_zipcode
		url = "#{ENV['OPEN_WEATHER_GEO_ZIP_ENDPOINT']}?zip=#{@search_key},IN&appid=#{ENV['OPEN_WEATHER_SECRET_KEY']}"
		response = HTTParty.get(url)
		parse_reponse(response)
	end

	# Get weather report data by passing place name.
	def fetch_by_place_name
		url = "#{ENV['OPEN_WEATHER_GEO_ENDPOINT']}?q=#{@search_key.downcase}&limit=1&appid=#{ENV['OPEN_WEATHER_SECRET_KEY']}"
		response = HTTParty.get(url)&.first
		parse_reponse(response)
	end

	# Parse the response and get lattitude and longitude.
	def parse_reponse(response)
		return "" if response.nil?

		@lat = response["lat"]
		@lon = response["lon"]
	end

	# Fetch weather report by passing lattitude and longitude.
	def fetch_weather_by_lat_lon
		return "" unless ENV['OPEN_WEATHER_ENDPOINT'] || ENV['OPEN_WEATHER_SECRET_KEY']

		url = "#{ENV['OPEN_WEATHER_ENDPOINT']}?lat=#{@lat}&lon=#{@lon}&appid=#{ENV['OPEN_WEATHER_SECRET_KEY']}&units=metric"
		response = HTTParty.get(url)
		parse_weather_data(response)
	end

	# Parse the response JSON data.
	def parse_weather_data(response)
		return "" if response.nil?
		@report =
		{
			place: response['name'],
			country: response['sys']['country'],
			lat: response['coord']['lat'],
			lon: response['coord']['lon'],
			current_temprature: response['main']['temp'].to_s + " C",
			humidity: response['main']['humidity'],
			minimum: response['main']['temp_min'].to_s + " C",
			maximum: response['main']['temp_max'].to_s + " C",
			weather: response['weather'][0]['description'].capitalize,
			wind: response['wind']['speed']
		}

		return { data: @report }
	end
end