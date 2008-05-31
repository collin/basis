require "fileutils"
require "rubygems"
require "rake/gempackagetask"
require "spec/rake/spectask"

require "./lib/basis/version.rb"

basis_gemspec = Gem::Specification.new do |s|
  s.name             = "basis"
  s.version          = Basis::VERSION
  s.platform         = Gem::Platform::RUBY
  s.has_rdoc         = true
  s.extra_rdoc_files = ["README.rdoc"]
  s.summary          = "Basis is smart project skeletons. And generators. And cake."
  s.description      = s.summary
  s.author           = "John Barnette"
  s.email            = "jbarnette@rubyforge.org"
  s.homepage         = "http://github.com/jbarnette/basis"
  s.require_path     = "lib"
  s.autorequire      = "basis"
  s.files            = %w(README.rdoc Rakefile) + Dir.glob("{lib,specs}/**/*")
  
  # Uncomment this to add a dependency
  # s.add_dependency "foo"
end

Rake::GemPackageTask.new(basis_gemspec) do |pkg|
  pkg.gem_spec = basis_gemspec
end

namespace :gem do
  namespace :spec do
    desc "Update basis.gemspec"
    task :generate do
      File.open("basis.gemspec", "w") do |f|
        f.puts(basis_gemspec.to_ruby)
      end
    end
  end
end

task :install => :package do
  sh %{sudo gem install pkg/basis-#{Basis::VERSION}}
end

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
  t.spec_opts = ["--options", "spec/spec.opts"]
end

task :default => :spec

desc "Remove all generated artifacts"
task :clean => :clobber_package
