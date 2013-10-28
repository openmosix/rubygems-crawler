rubygems-crawler
================

A little utility to download rubygems.org information - used for an ElasticSearch demo at RubyConf 2013

## Install

You can use the rubygems installation with:

    gem install rubygems-crawler

## Usage

We're assuming you have a running instance of MongoDB on localhost 27017 (if not, set the MONGO_URI environment variable to a mongodb url - like mongodb://10.0.0.1:27010/).

The crawler is made of 2 executables:

    rubygems-web-crawler
    
and

    rubygems-gems-crawler
    
    
The first one is the seeder of the crawler: it downloads all the available names of the gems and save the names into Mongo (by default on 'rubygems' database, collection 'gems').

The second one iterates through all the gem names saved in Mongo, and enrich each record with new data coming from the RubyGems APIs.

### Seeding the database

To seed the Mongo database with *all* the gems available at RubyGems.org:

    rubygems-web-crawler
    
The seeder will connect online, downloading the /gems page of rubygems.org. You should see a console output like:
    
    Acquiring http://rubygems.org/gems?letter=A
    [RubyGems Web Crawler] [http://rubygems.org/gems?letter=A] - Acquired 30 gems
    Acquiring http://rubygems.org/gems?letter=A&page=2
    [RubyGems Web Crawler] [http://rubygems.org/gems?letter=A&page=2] - Acquired 30 gems
    Acquiring http://rubygems.org/gems?letter=A&page=3
    [RubyGems Web Crawler] [http://rubygems.org/gems?letter=A&page=3] - Acquired 30 gems
    Acquiring http://rubygems.org/gems?letter=A&page=4
    ...
    
Several (thousands) pages after this, you will have all gem names saved into MongoDB - database "rubygems", collection "gems".

You can test - using the Mongo console - what's happening in your local database:

    ᐅ mongo
    MongoDB shell version: 2.2.0
    connecting to: test
    > use rubygems
    switched to db rubygems
    > db.gems.count()
    64741
    > 


### Downloading all the gems data

After you have downloaded all gems' names into your local database, let's run the gems-crawler. The gem crawler will use RubyGems.org APIs to enrich all the gem records with extra data.

To run it:

    rubygems-gems-crawler 

You should see a similar output:

    [RubyGems Web Crawler] Acquiring data for gem a
    [RubyGems Web Crawler] Acquiring data for gem a13g
    [RubyGems Web Crawler] Acquiring data for gem a2_printer
    [RubyGems Web Crawler] Acquiring data for gem a2ws
    ...

Several thousands gems later, all the data is now loaded into your local database

Let's see what we have in Mongo now:

    ᐅ mongo
    MongoDB shell version: 2.2.0
    connecting to: test
    > use rubygems
    switched to db rubygems
    > db.gems.find(name: 'a').pretty()
    Mon Oct 28 19:09:45 SyntaxError: missing ) after argument list (shell):1
    > db.gems.find({name: 'a'}).pretty()
    {
      "_id" : ObjectId("52684713bc2b36832b000001"),
      "name" : "a",
      "downloads" : 16520,
      "version" : "0.1.1",
      "version_downloads" : 10144,
      "platform" : "ruby",
      "authors" : " Author",
      "info" : "Summary",
      "licenses" : null,
      "project_uri" : "http://rubygems.org/gems/a",
      "gem_uri" : "http://rubygems.org/gems/a-0.1.1.gem",
      "homepage_uri" : "http://google.com",
      "wiki_uri" : null,
      "documentation_uri" : null,
      "mailing_list_uri" : null,
      "source_code_uri" : null,
      "bug_tracker_uri" : null,
      "dependencies" : {
        "development" : [ ],
        "runtime" : [ ]
      },
      "versions" : [
        {
          "authors" : " Author",
          "built_at" : "2010-05-27T16:00:00Z",
          "description" : null,
          "downloads_count" : 10144,
          "number" : "0.1.1",
          "summary" : "Summary",
          "platform" : "ruby",
          "prerelease" : false,
          "licenses" : null,
          "requirements" : null
        },
        {
          "authors" : " Author",
          "built_at" : "2010-05-27T16:00:00Z",
          "description" : null,
          "downloads_count" : 6376,
          "number" : "0.1.0",
          "summary" : "Summary",
          "platform" : "ruby",
          "prerelease" : false,
          "licenses" : null,
          "requirements" : null
        }
      ],
      "owners" : [
        {
          "email" : "degcat@126.com"
        }
      ]
    }


### Ain't Nobody Got Time For That

In a little hurry?

Well you can also download the full bson from [here](https://github.com/openmosix/rubygems-crawler/blob/master/downloads/mongo_dump.tbz2)

Download the package and untar-bzipit:

   $ tar -jxvf mongo_dump.tbz2

Then import the full data into your local MongoDB:

   mongorestore -d rubygems mongo_dump/
