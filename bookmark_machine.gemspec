require_relative './lib/bookmark_machine/version'

Gem::Specification.new do |s|
  s.name        = 'bookmark_machine'
  s.version     = BookmarkMachine::VERSION
  s.authors     = ['Adam Sanderson']
  s.email       = ['netghost@gmail.com']
  s.homepage    = 'https://github.com/adamsanderson/bookmark_machine'
  
  s.summary     = 'Reads and writes netscape bookmark files.'
  s.description = 'Parse and format bookmarks'
  s.licenses    = 'MIT'

  s.files        = Dir.glob('{bin,lib}/**/*') + ["README.markdown"]
  s.require_path = 'lib'
  
  s.add_runtime_dependency "nokogiri", "~> 1.6"
  
  s.add_development_dependency "minitest", "~> 5.9"
  s.add_development_dependency "bundler", "~> 1.8"
  s.add_development_dependency "rake", "~> 10.0"
end