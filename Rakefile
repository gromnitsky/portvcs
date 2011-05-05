# -*-ruby-*-

require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'

spec = Gem::Specification.new() {|i|
  i.name = "portvcs"
  i.version = `bin/#{i.name} -V`
  i.summary = "FreeBSD ports commits history viewer that doesn't require neither local ports tree nor CVS checkouts"
  i.description = i.summary + '.'
  i.author = 'Alexander Gromnitsky'
  i.email = 'alexander.gromnitsky@gmail.com'
  i.homepage = "http://github.com/gromnitsky/#{i.name}"
  
  i.platform = Gem::Platform::RUBY
  i.required_ruby_version = '>= 1.9.2'
  i.files = FileList['lib/**/*', 'bin/*', 'doc/*', 'etc/*', '[A-Z]*', 'test/**/*']

  i.executables = FileList['bin/*'].gsub(/^bin\//, '')
  
  i.test_files = FileList['test/test_*.rb']
  
  i.rdoc_options << '-m' << 'doc/README.rdoc'
  i.extra_rdoc_files = FileList['doc/*']
  
  i.add_development_dependency('open4', '>=  1.0.1')
}

Rake::GemPackageTask.new(spec).define()

task(default: %(repackage))

Rake::RDocTask.new('doc') {|i|
  i.main = 'doc/README.rdoc'
  i.rdoc_files = FileList['doc/*', 'lib/**/*.rb']
  i.rdoc_files.exclude("lib/**/plugins")
}

Rake::TestTask.new() {|i|
  i.test_files = FileList['test/test_*.rb']
}
