require "test_helper"

class SketchesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sketches_new_url
    assert_response :success
  end

  test "should get create" do
    get sketches_create_url
    assert_response :success
  end

  test "should get show" do
    get sketches_show_url
    assert_response :success
  end
end