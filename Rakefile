# -*-ruby-*-

require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'

spec = Gem::Specification.new() {|i|
  i.name = "portvcs"
  i.version = `bin/#{i.name} -V`
  i.summary = "FreeBSD ports commit history viewer. Doesn't require neither local ports tree nor CVS checkouts."
  i.author = 'Alexander Gromnitsky'
  i.email = 'alexander.gromnitsky@gmail.com'
  i.homepage = "http://github.com/gromnitsky/#{i.name}"
  i.platform = Gem::Platform::RUBY
  i.required_ruby_version = '>= 1.9.2'
  i.files = FileList['lib/**/*', 'bin/*', 'doc/*', '[A-Z]*', 'test/**/*']

  i.executables = FileList['bin/*'].gsub(/^bin\//, '')
  i.default_executable = i.name
  
  i.test_files = FileList['test/test_*.rb']
  
  i.rdoc_options << '-m' << 'README.rdoc'
  i.extra_rdoc_files = FileList['doc/*']
  
#  i.add_dependency('activesupport', '>= 3.0.3')
  i.add_dependency('open4', '>=  1.0.1')
}

Rake::GemPackageTask.new(spec).define()

task(default: %(repackage))

Rake::RDocTask.new('doc') {|i|
  i.main = 'README.rdoc'
  i.rdoc_files = FileList['doc/*', 'lib/**/*.rb']
  i.rdoc_files.exclude("lib/**/plugins")
}

Rake::TestTask.new() {|i|
  i.test_files = FileList['test/test_*.rb']
}