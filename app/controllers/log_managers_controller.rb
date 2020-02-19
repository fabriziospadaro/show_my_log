require 'csv'
require 'multi_json'
require 'faraday'
require 'elasticsearch/api'

class LogManagersController < ActionController::Base
  CONNECTION = ::Faraday::Connection.new url: 'http://localhost:9200'

  def index
  end

  def process_file

    file = file_params["file"].tempfile
    file_path = File.open(Rails.root.join('input_data.txt'), 'w') {|f| f << file.read.force_encoding("UTF-8")}.path
    file.unlink
    batch_size = 5000
    index_start = 2
    line_count = `wc -l "#{file_path}"`.strip.split(' ')[0].to_i - index_start
    #`brew install watchman`
    repetitions = (line_count / batch_size)
    repetitions.times do |i|
      FileProcessorJob.perform_async(file_path, i * batch_size + index_start, batch_size, ["rfc3164", "custom_export"])
    end
    pending_lines = (line_count - repetitions * batch_size)
    if pending_lines > 0
      FileProcessorJob.perform_async(file_path, batch_size * repetitions + index_start, batch_size, ["rfc3164", "custom_export"])
    end
  end

  def file_params
    params.permit(:file)
  end
end
