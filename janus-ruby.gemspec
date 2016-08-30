require File.expand_path('../lib/janus_gateway/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'janus_gateway'
  s.version     = JanusGateway::VERSION
  s.summary     = 'janus-gateway client'
  s.description = 'janus-gateway API client'
  s.authors     = ['Cargo Media', 'kris-lab', 'tomaszdurka', 'njam']
  s.email       = 'tech@cargomedia.ch'
  s.files       = Dir['LICENSE*', 'README*', '{bin,lib}/**/*']
  s.homepage    = 'https://github.com/cargomedia/janus-gateway-ruby'
  s.license     = 'MIT'

  s.add_runtime_dependency 'faye-websocket', '~> 0.10.4'
  s.add_runtime_dependency 'eventmachine', '~> 1.2.0'
  s.add_runtime_dependency 'events', '~> 0.9.8'
  s.add_runtime_dependency 'concurrent-ruby', '~> 1.0.0'
  s.add_runtime_dependency 'em-http-request', '~> 1.1.3'

  s.add_development_dependency 'rake', '~> 10.5.0' # workaround for rubocop https://github.com/bbatsov/rubocop/pull/2931
  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'rubocop', '~> 0.41.2'
  s.add_development_dependency 'webmock', '~> 1.22', '>= 1.22.6'
end
