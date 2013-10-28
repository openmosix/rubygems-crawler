require 'gems'
require 'mongo'

# A very simple gems crawler for Rubygems.org
module RubyGems
  class GemsCrawler
    
    GRACE_PERIOD = 5  # be gentle
    
    def initialize(mongo)
      @mongo = mongo
    end
    
    def crawl_from(initial_name='a')
      #name: {'$gte' => initial_name} - to filter by name
      @mongo[:gems].find({owners: nil}, {fields: ["name"]}).each_slice(10) do |bulk|
        bulk.each do |mongo_doc|
          crawl(mongo_doc['name'])
          sleep GRACE_PERIOD  #be nice
        end
      end
    end
    
    def crawl(gem_name)
      STDOUT.puts "[RubyGems Web Crawler] Acquiring data for gem #{gem_name}"
      
      gem_object = Gems.info(gem_name)
      gem_object['versions'] = Gems.versions(gem_name)
      gem_object['owners'] = Gems.owners(gem_name)
      
      save(gem_object)
    rescue
      STDERR.puts "[RubyGems Web Crawler] Error while acquiring data for gem #{gem_name}"
    end
    
    # Save all the gem data into Mongo
    def save(gem_object)
      @mongo[:gems].find_and_modify(query: {name: gem_object['name']}, update: gem_object)
    end
    
  end
end