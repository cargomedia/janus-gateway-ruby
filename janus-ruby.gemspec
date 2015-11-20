require File.expand_path('../lib/janus/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'janus-ruby'
  s.version     = Janus::VERSION
  s.summary     = 'janus-gateway client'
  s.description = 'janus-gateway API client'
  s.authors     = ['Cargo Media', 'kris-lab', 'tomaszdurka', 'njam']
  s.email       = 'tech@cargomedia.ch'
  s.files       = Dir['LICENSE*', 'README*', '{bin,lib}/**/*']
  s.homepage    = 'https://github.com/cargomedia/janus-ruby'
  s.license     = 'MIT'

  s.add_runtime_dependency 'faye-websocket', '~> 0.10.1'
  s.add_runtime_dependency 'eventmachine', '~> 1.0.8'
  s.add_runtime_dependency 'event_emitter', '~> 0.2.5'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.0'
end
