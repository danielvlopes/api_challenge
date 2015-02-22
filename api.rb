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
  end

  status 200
  { params[:id] => params[:tags] }.to_json
end

# GET /tags/:entity_type/:entity_id
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

# DELETE /tags/:entity_type/:entity_id

delete "/tags/:type/:id" do
  require_params!(:type, :id)
  key = "#{params[:type]}:#{params[:id]}:tags"
  result = @redis.del(key)

  if result > 0
    status 200
    result.to_json
  else
    status 404
    { params[:id] => "" }.to_json
  end
end

# HELPERS

# def add_counter(tags)
#   HSET myhash field 5
#   tags.each do |tag|
#   end
# end

def require_params!(*keys)
  keys.each do |key|
    if params[key].nil? || params[key].empty?
      halt 500, { error: "Param #{key} is required!" }.to_json
    end
  end
end