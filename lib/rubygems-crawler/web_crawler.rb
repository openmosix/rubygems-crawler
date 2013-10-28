require 'net/http'
require 'nokogiri'
require 'mongo'

# A very simple web crawler for Rubygems.org
module RubyGems
  class WebCrawler
    
    BASE_URL = 'http://rubygems.org'
    REQUEST_HEADERS = {'User-Agent'=>'rubygems-crawler'}
    TIMEOUT=30
    GRACE_PERIOD=1  #Sleep for a while - be gentle
    
    def initialize(mongo)
      @mongo = mongo
    end
    
    # Crawl all the pages of RubyGems, given an initial letter and save the data into MongoDB
    def crawl(letter='A')
      url = "#{BASE_URL}/gems?letter=#{letter}"
      while url && gems = download_page(url)
        save_gems(gems[:gems])
        STDOUT.puts "[RubyGems Web Crawler] [#{url}] - Acquired #{gems[:gems].count} gems"
        
        url = (gems[:next_path]) ? "#{BASE_URL}#{gems[:next_path]}" : nil
        sleep GRACE_PERIOD
      end
    end
    
    # Download an HTML page given an url, parse the HTML and convert the result back into an HASH
    def download_page(url)
      STDOUT.puts "Acquiring #{url}"
      
      network_res = network_call(url, REQUEST_HEADERS, TIMEOUT)
      return parse_content(network_res[:response]) if network_res && network_res[:response]
    end
    
    #Execute a GET HTTP call to url given the specified headers
    def network_call(url, request_headers={}, timeout = nil)

      retries = 0
      begin
        uri = URI.parse(url.ascii_only? ? url : URI.escape(url))
        http = Net::HTTP.new(uri.host, uri.port)

        unless timeout.nil?
          http.open_timeout = timeout
          http.read_timeout = timeout
        end

        request = Net::HTTP::Get.new(uri.request_uri, request_headers)
        response = http.request(request)

      rescue Timeout::Error, Net::HTTPBadResponse, EOFError => e
        retries += 1
        retry unless retries > 3
        return {error: e, code: 0}
      end

      result = {:code=>response.code.to_i}    
      result[:response] = response.body if response.code.to_s == '200'
      result
    end
    
    # Parse the HTML of the page extracting gem names and total number of pages
    def parse_content(response)
      gem_res = {:gems => [], :next_path => nil}
      
      html_doc = Nokogiri::HTML(response)
      
      html_doc.css('.gems li a>strong').each do |node|
        node.content =~ /(.+)\s\(.+\)/
        gem_res[:gems] << $1
      end      
  
      next_page = html_doc.css('.next_page').first
      if next_page
        gem_res[:next_path] = next_page.attr('href')
      end
      
      gem_res
    end
    
    # Save all the gem names into Mongo
    def save_gems(gems)
      gems.each {|gem_name| @mongo[:gems].insert({name: gem_name}) }
    end
    
  end
end