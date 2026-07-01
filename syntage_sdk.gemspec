require_relative 'lib/syntage_sdk/version'

Gem::Specification.new do |spec|
  spec.name = 'syntage_sdk'
  spec.version = SyntageSdk::VERSION
  spec.authors = ['Local Solutions IT']

  spec.summary = 'Ruby SDK for the Syntage API.'
  spec.description = 'Centralized configuration and authenticated access to the Syntage API.'
  spec.required_ruby_version = '>= 3.4.0'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.24'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
