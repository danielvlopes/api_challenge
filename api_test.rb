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

  # def test_post_a_new_tag
  #   post "/tag"
  # end
end

