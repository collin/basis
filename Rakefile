require "rubygems"
require "rake/gempackagetask"
require "spec/rake/spectask"

require "./lib/basis/version.rb"

module Basis
  GEM = "basis"
  AUTHOR = "John Barnette"
  EMAIL = "jbarnette@rubyforge.org"
  HOMEPAGE = "http://github.com/jbarnette/basis"
  SUMMARY = "Basis is smart project skeletons. And components. And cake"
end

spec = Gem::Specification.new do |s|
  s.name = Basis::GEM
  s.version = Basis::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.summary = Basis::SUMMARY
  s.description = s.summary
  s.author = Basis::AUTHOR
  s.email = Basis::EMAIL
  s.homepage = Basis::HOMEPAGE
  
  # Uncomment this to add a dependency
  # s.add_dependency "foo"
  
  s.require_path = "lib"
  s.autorequire = Basis::GEM
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{Basis::GEM}-#{Basis::VERSION}}
end

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
  t.spec_opts = ["--options", "spec/spec.opts"]
end

# Rake::Task[:default].prerequisites.clear
task :default => :spec
