# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'amico/version'

Gem::Specification.new do |s|
  s.name        = "amico"
  s.version     = Amico::VERSION
  s.authors     = ["David Czarnecki"]
  s.email       = ["dczarnecki@agoragames.com"]
  s.homepage    = "https://github.com/agoragames/amico"
  s.summary     = %q{Relationships (e.g. friendships) backed by Redis}
  s.description = %q{Relationships (e.g. friendships) backed by Redis}

  s.rubyforge_project = "amico"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('redis')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
end
