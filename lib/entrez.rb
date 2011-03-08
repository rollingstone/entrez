require 'httparty'

class Entrez

  include HTTParty
  base_uri 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils'
  default_params tool: 'ruby', email: (ENV['ENTREZ_EMAIL'] || raise('please set ENTREZ_EMAIL environment variable'))

  class << self

    def efetch(db, params = {})
      respect_query_limit
      request_times << Time.now.to_f
      get '/efetch.fcgi', :query => {db: db}.merge(params)
    end

    def request_times
      @request_times ||= []
    end

    private

    def respect_query_limit
      three_requests_ago = request_times[-3]
      return unless three_requests_ago
      three_requests_ago = three_requests_ago.to_f
      now = Time.now.to_f
      enough_time_has_passed = now > three_requests_ago + 1
      unless enough_time_has_passed
        STDERR.puts "sleeping #{now - three_requests_ago}"
        sleep(now - three_requests_ago)
      end
    end

  end

end
