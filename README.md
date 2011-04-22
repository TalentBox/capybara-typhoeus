Capybara-restfulie
==================

This gems makes it possible to use [Faraday](http://github.com/technoweenie/faraday) for remote testing.

This gem is a [Capybara](http://github.com/jnicklas/capybara) extension. The structure of the gem is taken from the work done on [Capybara-mechanize](http://github.com/jeroenvandijk/capybara-mechanize).

### Installation

    gem install capybara-faraday

### Usage without Cucumber

    require 'capybara/faraday'

### Usage with Cucumber and tags

A @faraday tag is added to your hooks when you add the following line to your env.rb

    require 'capybara/faraday/cucumber'

The following scenario will then be using the Faraday driver

    @faraday
    Scenario: do something with the API
      Given I send and accept JSON
      When I send a GET request to /users
      
If you want to use a specific faraday supported adapter, you need to install the dependency and then specify the tag matching it:

To use Typhoeus

    @faraday_typhoeus
    Scenario: do something with the API
      Given I send and accept JSON
      When I send a GET request to /users
    
To use Patron

    @faraday_patron
    Scenario: do something with the API
      Given I send and accept JSON
      When I send a GET request to /users    
      
### Remote testing

When you want to use this driver to test a remote application. You have to set the app_host:

    Capybara.app_host = "http://www.yourapp.com"
    
Note that I haven't tested this case for my self yet. The Capybara tests pass for this situation though so it should work! Please provide me with feedback if it doesn't.

## Running tests

For the tests to make sense, you need to simulate a remote server, simply add this line to your hosts file:

    127.0.0.1 capybara-testapp.heroku.com

Run bundler

    bundle install

Then you are ready to run the test like so

    rake spec

Caveats
-------

The focus being to provide a working driver to test APIs, not all Capybara goodness are implemented.
Everything related to submitting forms, clicking buttons, clicking checkboxes or javascript will not work with this driver.

Todo
----

Note on Patches/Pull Requests
-----------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------
Copyright (c) 2010 Tron Jonathan and HALTER Joseph. See LICENSE for details.