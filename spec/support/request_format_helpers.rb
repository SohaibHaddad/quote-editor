module RequestFormatHelpers
  def turbo_stream_headers
    {
      "ACCEPT" => Mime[:turbo_stream].to_s
    }
  end
end

RSpec.configure do |config|
  config.include RequestFormatHelpers, type: :request
end
