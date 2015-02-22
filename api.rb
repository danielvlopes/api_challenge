require 'sinatra'
require 'json'

before do
  @redis = Redis.new
  content_type :json
end

# - Entity Type, e.g. 'Product', 'Article'
# - Entity Identifier, e.g. '1234', '582b5530-6cdb-11e4-9803-0800200c9a66'
# - Tags, e.g. ['Large', 'Pink', 'Bike']

post '/tag' do
  require_params!(:type, :id, :tags)
  key = "#{params[:type]}:#{params[:id]}:tags"

  @redis.multi do
    @redis.del(key)
    @redis.sadd(key, params[:tags])
    increment_stats(params[:tags])
  end

  status 200
  { params[:id] => params[:tags] }.to_json
end

get "/tags/:type/:id" do
  require_params!(:type, :id)
  key = "#{params[:type]}:#{params[:id]}:tags"
  result = @redis.smembers(key)

  if result.empty?
    status 404
    { params[:id] => [] }.to_json
  else
    status 200
    { params[:id] => result }.to_json
  end
end

delete "/tags/:type/:id" do
  require_params!(:type, :id)
  key = "#{params[:type]}:#{params[:id]}:tags"
  tags = @redis.smembers(key)
  result = []

  result = @redis.multi do
    @redis.del(key)
    increment_stats(tags, -1)
  end

  if !result.last.nil? && result.last > 0
    status 200
    result.to_json
  else
    status 404
    { params[:id] => "" }.to_json
  end
end

# Retrives statistics about all tags
# e.g. [{tag: 'Bike', count: 5}, {tag: 'Pink', count: 3}]

get "/stats" do
  stats = @redis.hgetall("tags:stats")
  status 200
  stats.to_json
end

# HELPERS

def increment_stats(tags, value=1)
  tags.each do |tag|
    @redis.hincrby("tags:stats", tag, value)
  end
end

def require_params!(*keys)
  keys.each do |key|
    if params[key].nil? || params[key].empty?
      halt 500, { error: "Param #{key} is required!" }.to_json
    end
  end
end