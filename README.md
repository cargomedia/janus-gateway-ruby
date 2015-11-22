janus-ruby [![Build Status](https://travis-ci.org/cargomedia/janus-ruby.svg)](https://travis-ci.org/cargomedia/janus-ruby)
==========
Minimalistic [janus-gateway](https://github.com/meetecho/janus-gateway) client for ruby

Installation
------------
```
gem install janus-ruby
```

API coverage
------------
Current implementation support only a few of API features. For more details please follow official documentation of [REST API](https://janus.conf.meetecho.com/docs/rest.html)

|Resource       |Get All |Get One |Create |Update |Delete |
|:--------------|:------:|:------:|:-----:|:-----:|:-----:|
|Session        |        |        | +     |       | +     |
|Plugin         |        |        | +     |       |       |

Library usage
-------------

Source code itself is well-documented so when writing code it should auto-complete and hint in all supported usages.


### Client
Most important part of the api is client. In order to make any request you need to instantiate client with correct params.

```ruby
client = Janus::Client.new('url')
```

This client is used by all other classes connecting to api no matter if it's Resource or helper class like Agent.

### Resources
Each resource has built-in event emitter to handle basic behaviours like `create` and `destroy`. Additionally the creation of resources can be chained.
#### Create
```ruby
client = Janus::Client.new('url')
session = Janus::Resource::Session.new(client)
plugin = Janus::Resource::Plugin.new(plugin, 'plugin-name')
```

#### Event
```
client = Janus::Client.new('url')
session = Janus::Resource::Session.new(client)

session.on :create do |session|
  # do something
end

session.on :destroy do |session|
  # do something
end
```

#### Chain
```
client = Janus::Client.new('url')
session = Janus::Resource::Session.new(client)

session.create.then do |session|
  # do something with success
end.rescue fo |error|
  # do something with error
end
```
