# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adequate_json/version'

Gem::Specification.new do |spec|
  spec.name          = 'adequate_json'
  spec.version       = AdequateJson::VERSION
  spec.authors       = ['Jef Mathiot', 'Issam Tribak', 'Wilfried Tacquard']
  spec.email         = ['jeff.mathiot@gmail.com', 'issam.tribak@mysofie.fr', 'wilfried.tacquard@mysofie.fr']

  spec.summary       = 'Yet another JSON serialization library'
  spec.description   = 'Adequate Json is a gem that simplifies the process of serializing JSON for API responses.'
  spec.homepage      = 'https://github.com/EverestHC-mySofie/adequate_json'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/EverestHC-mySofie/adequate_json'
    spec.metadata['changelog_uri'] = 'https://github.com/EverestHC-mySofie/adequate_json'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'jbuilder'

  spec.add_development_dependency 'attr_extras'
  spec.add_development_dependency 'bundler', '~> 2.5'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'

  spec.required_ruby_version = '~> 3.0'
end
