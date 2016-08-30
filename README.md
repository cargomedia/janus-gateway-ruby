janus-gateway-ruby
==================
Minimalistic client for the [Janus](https://github.com/meetecho/janus-gateway) WebRTC gateway.

[![Build Status](https://img.shields.io/travis/cargomedia/janus-gateway-ruby/master.svg)](https://travis-ci.org/cargomedia/janus-gateway-ruby)
[![Gem Version](https://img.shields.io/gem/v/janus_gateway.svg)](https://rubygems.org/gems/janus_gateway)

Installation
------------
```
gem install janus_gateway
```

API coverage
------------
Current implementation support only a few of API features. For more details please follow official documentation of [REST API](https://janus.conf.meetecho.com/docs/rest.html)

Library usage
-------------

Source code itself is well-documented so when writing code it should auto-complete and hint in all supported usages.

### Client
In order to make any request you need to instantiate client with correct transport layer (see transport section).

```ruby
ws = JanusGateway::Transport::WebSocket.new('ws://localhost:8188/janus')
client = JanusGateway::Client.new(ws)
```

This client is used by all other classes connecting to api no matter if it's Resource or helper class like Agent.

### Transports
Client allows to use multiple, supported by Janus transportation layers. Currently the `WebSocket` transport is implemented and is the default.

```ruby
ws = JanusGateway::Transport::WebSocket.new('ws://localhost:8188/janus')
```

### Resources
Each resource has built-in event emitter to handle basic behaviours like `create` and `destroy`. Additionally the creation of resources can be chained.
There are two types of resources: Janus-API resource and Plugin-API (please see Plugin section).

You can bind on events:
```ruby
session = JanusGateway::Resource::Session.new(client)

session.on :create do
  # do something
end

session.on :destroy do
  # do something
end

session.create
```

Resource creation and destroying are asynchronous operations which return a `Concurrent::Promise`:
```ruby
session = JanusGateway::Resource::Session.new(client)

session.create.then do |session|
  # do something with success
end.rescue do |error|
  # do something with error
end
```

#### Session
Create new session:
```ruby
session = JanusGateway::Resource::Session.new(client)
session.create
```

Destroy a session:
```ruby
session.destroy
```

#### Plugin
Create new plugin:
```ruby
plugin = JanusGateway::Resource::Plugin.new(client, session, 'plugin-name')
plugin.create
```

Destroy a plugin:
```ruby
plugin.destroy
```

### Plugins
Janus support for native and custom [plugins](https://janus.conf.meetecho.com/docs/group__plugins.html).

#### Rtpbrodcast plugin
This is custom plugin for `RTP` streaming. Please find more details in official [repository](https://github.com/cargomedia/janus-gateway-rtpbroadcast).
Plugin must be installed and active in `Janus` server.

Plugin resource supports `events` and `chaining` in the same way like `Janus` resource.

#### List
Endpoint allows to retrieve the list of current mountpoints.

##### Mountpoint create
Endpoint allows to create `RTP` mountpoint.

```ruby
ws = JanusGateway::Transport::WebSocket.new('ws://localhost:8188/janus')
client = JanusGateway::Client.new(ws)

client.on :open do
  JanusGateway::Resource::Session.new(client).create.then do |session|
    JanusGateway::Plugin::Rtpbroadcast.new(client, session).create.then do |plugin|
      JanusGateway::Plugin::Rtpbroadcast::Mountpoint.new(client, plugin, 'test-mountpoint').create.then do |mountpoint|
        # do something with mountpoint
      end
    end
  end
end

client.run
```

#### Audioroom plugin
This is custom plugin for `audio` bridging. Please find more details in official [repository](https://github.com/cargomedia/janus-gateway-audioroom).
Plugin must be installed and active in `Janus` server.

Plugin resource supports `events` and `chaining` in the same way like `Janus` resource.

##### List
Endpoint allows to retrieve the list of current audio rooms.

Development
-----------

Install dependencies:
```
bundle install
```

Run tests:
```
bundle exec rspec
```

Release a new version:

1. Bump the version in `lib/janus_gateway/version.rb`, merge to master.
2. Push a new tag to master.
3. Release to RubyGems with `bundle exec rake release`.
