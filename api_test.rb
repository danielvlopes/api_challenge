require_relative 'test_helper'

class ApiTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def setup
    @redis = Redis.new
  end

  def teardown
    @redis.flushdb
  end

  def app
    Sinatra::Application
  end

  def test_get_tags_for_a_given_entity
    @redis.sadd("Test:1000:tags", %w(T1 T2 T3))
    get "/tags/Test/1000"
    data = JSON.parse(last_response.body)
    assert_equal %w[T1 T2 T3].sort, data["1000"].sort
  end

  def test_post_a_new_tag
    post "/tag", {type: "Test", id: "1000", tags: %w(T1 T2 T3)}
    data = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal %w(T1 T2 T3), data["1000"].sort
  end

  def test_post_tag_fails_properly_with_invalid_params
    post "/tag", {id: "1000", tags: %w(T1 T2 T3)}
    assert_equal 500, last_response.status
    post "/tag", {type: "Product", tags: %w(T1 T2 T3)}
    assert_equal 500, last_response.status
    post "/tag", {id: "1000", tags: %w(T1 T2 T3)}
    assert_equal 500, last_response.status
  end

  def test_delete_existing_entity
    @redis.sadd("Test:1000:tags", %w(T1 T2 T3))

    delete "/tags/Test/1000"
    assert_equal 200, last_response.status
    assert_equal "1", last_response.body
  end

  def test_deleting_an_entity_that_doesnt_exist
    delete "/tags/Test/SomeCrazyID"
    assert_equal 404, last_response.status
  end

  def test_get_stats
    post "/tag", {type: "Product", id: "1000", tags: %w(BMX Pink)}
    post "/tag", {type: "Product", id: "1001", tags: %w(BMX Black)}
    get "/stats"
    expected_stats = {"BMX"=>"2", "Pink"=>"1", "Black"=>"1"}
    assert_equal expected_stats, JSON.parse(last_response.body)
    delete "/tags/Product/1000"
    get "/stats"
    expected_stats = {"BMX"=>"1", "Pink"=>"0", "Black"=>"1"}
    assert_equal expected_stats, JSON.parse(last_response.body)
  end

  def test_get_stats_for_one_tag
    post "/tag", {type: "Product", id: "1000", tags: %w(BMX Pink)}
    post "/tag", {type: "Product", id: "1001", tags: %w(BMX Black)}

    get "/stats/BMX"
    assert_equal "2", last_response.body

    get "/stats/Pink"
    assert_equal "1", last_response.body
  end

end

