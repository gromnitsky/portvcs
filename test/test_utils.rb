require_relative 'helper'

class TestUtils < MiniTest::Unit::TestCase
  def setup
    cmd 'foobar' # cd to tests directory
    @ptree = Dir.pwd + '/' + 'ports'
  end

  def test_name_resolution
    save = Dir.pwd
    
    assert_equal(nil, Utils.port_extract_name(nil, @ptree))
    assert_equal(nil, Utils.port_extract_name('', nil))
    assert_equal(nil, Utils.port_extract_name('    ', nil))
    assert_equal(nil, Utils.port_extract_name('foo    ', nil))
    assert_equal(nil, Utils.port_extract_name('/', nil))
    assert_equal(nil, Utils.port_extract_name('////////// //////', nil))
    assert_equal(nil, Utils.port_extract_name('//////////', nil))
    assert_equal(nil, Utils.port_extract_name('/foo', nil))
    assert_equal(nil, Utils.port_extract_name('foo/', nil))
    
    assert_equal(['foo/bar'], Utils.port_extract_name('/foo/bar', nil))
    assert_equal(['q/w', 'e'], Utils.port_extract_name('/q/w/e', nil))
    assert_equal(['q/w/e', 'r'], Utils.port_extract_name('/q/w/e/r', nil))
    assert_equal(nil, Utils.port_extract_name('/q/w/e/r/t', nil))
    assert_equal(nil, Utils.port_extract_name('/q/w/e/r/t/y/u/i/o', nil))

    Dir.chdir @ptree
    assert_equal(nil, Utils.port_extract_name('program', @ptree))
    assert_equal(['category/program'],
                 Utils.port_extract_name('category/program', @ptree))
    assert_equal(['category/program', 'Makefile'],
                 Utils.port_extract_name('category/program/Makefile', @ptree))

    Dir.chdir 'category'
    assert_equal(nil, Utils.port_extract_name('program', @ptree))

    Dir.chdir 'program'
    assert_equal(["category/program", "pkg-descr"],
                 Utils.port_extract_name('pkg-descr', @ptree))

    assert_equal(["category/program/files", "patch-aa"],
                 Utils.port_extract_name('files/patch-aa', @ptree))
    
    Dir.chdir 'files'
    assert_equal(["category/program/files", "patch-aa"],
                 Utils.port_extract_name('patch-aa', @ptree))

    Dir.chdir save
  end

  def test_config
    t = { foo: 'bar' }
    t_exp = {
      foo: 'bar', host: '127.0.0.1', port: 2401, user: 'anonymous',
      pass: 'anoncvs', cvsroot: '/usr/local/cvsroot', ports_tree: ''
    }

    assert_equal('semis/localhost_cvs.yaml',
                 Utils.config_load(t, 'semis/localhost_cvs.yaml', nil))
    assert_equal(t_exp, t)

    assert_raises(RuntimeError) {
      Utils.config_load(t, 'semis/localhost_cvs_incomplete.yaml', nil)
    }
  end

end
