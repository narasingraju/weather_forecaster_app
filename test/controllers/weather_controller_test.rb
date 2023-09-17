class WeatherControllerTest < ActionDispatch::IntegrationTest
	test "should get weather_info" do
    get weather_info_url
    assert_response :success
  end

  test "should redirect to weather_info" do
    get weather_info_url(search: "523113")
    assert_equal "weather_info", @controller.action_name
    assert_response :success
    assert_equal "/weather-info", path
    assert_equal true, response.parsed_body.include?("15.1739") # lat
    assert_equal true, response.parsed_body.include?("Kandukūr") # palce
  end
end