class FileProcessorJob
  include Sidekiq::Worker
  sidekiq_options backtrace: true, queue: 'csvreplica_import', retry: 10

  def perform(file_name, start, batch_size)
    IO.readlines(file_name)[start..(start + batch_size)].each do |line|
      values = line.gsub("\n", "").split(";")
      attribute = {}
    end
  end
end