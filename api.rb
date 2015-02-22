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
  content_type :json
  { params[:id] => params[:tags] }.to_json
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