class FileProcessorJob
  include Sidekiq::Worker
  sidekiq_options queue: :show_my_log_import, backtrace: true, retry: 10

  def perform(file_name, start, batch_size, processors)
    client = ElasticClient.new
    IO.readlines(file_name)[start..(start + batch_size)].each do |line|
      begin
        attribute = {}
        processors.each do |processor|
          attribute.merge!(send(:"process_line_#{processor.downcase}", line))
        end
        id = (attribute["application"] + attribute["date"] + attribute["time"] + attribute["u"].to_s).gsub!(/[^0-9A-Za-z]/, '')
      rescue => e
        puts "*" * 10
        puts "#{e.message}\n line: #{line}"
        next
      end
      client.perform_request("put", "show_my_log/create/#{id}", attribute)
    end
    p "Done writing #{batch_size} lines from line: #{start}"
  end


  def process_line_rfc3164(line)
    raw_value = line.split("<101>")[1]
    values = raw_value.split(" ")[4].split(":")[1].split(";")
    attribute = {}
    attribute["priority"] = line[/#{"<"}(.*?)#{">"}/m, 1]
    attribute["application"] = raw_value.split(" ")[4].split(":")[0]
    values.each do |data|
      parsed = data.split("=")
      attribute[parsed[0]] = parsed[1]
    end
    attribute
  end

  def process_line_custom_export(line)
    raw_value = line.split("<101>")[0]
    attribute = {}
    ["date", "time", "level", "name", "host", "category", "program"].each_with_index do |k, i|
      attribute[k] = raw_value.split(",")[i]
    end
    attribute
  end
end