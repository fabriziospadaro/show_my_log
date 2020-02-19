require 'multi_json'
require 'faraday'
require 'elasticsearch/api'
class ElasticClient
  include Elasticsearch::API

  CONNECTION = ::Faraday::Connection.new url: 'http://localhost:9200'

  def perform_request(method, path, body)
    CONNECTION.run_request(
        method.downcase.to_sym,
        path,
        (body ? MultiJson.dump(body) : nil),
        {'Content-Type' => 'application/json'}
    )
  end
end