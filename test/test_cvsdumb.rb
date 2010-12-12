require_relative 'helper'

class TestCVSDumb < MiniTest::Unit::TestCase
  CMD = 'portvcs'
  CONFIG = 'semis/localhost_cvs.yaml'
  MSG = 'This test requires a running CVS server on localhost with auth credentials
listed in semis/localhost_cvs.yaml file'
  
  def setup
    cmd 'foobar' # cd to tests directory

    @skip_log_of_the_something = true
    # this probably won't work on your machine
    if ENV.key?('CVSROOT').to_s !~ /^\s*$/
      cd 'semis/cvstest'
      cmd_run("rm -rf '" + ENV['CVSROOT']+'/test/portvcs' + "'")
      r = cmd_run("cvs import -m 'Huh?' test foo bar")
      if r[0] != 0
        warn("cannot import a test file into #{ENV['CVSROOT']}: "+r[1..-1].join('; '))
      else
        @skip_log_of_the_something = false
      end
      cd '../..'
    end
  end

  def test_version
    r = cmd_run("#{cmd CMD} --config #{CONFIG} --vcs-version")
    assert_equal(0, r[0], MSG)
    assert_match(/Concurrent Versions System \(CVS\) 1.11/, r[2])
  end

  def test_log_of_the_something
    skip('cvsroot on localhost is not ready') if @skip_log_of_the_something
    r = cmd_run("#{cmd CMD} --config #{CONFIG} test/portvcs")
    assert_equal(0, r[0], MSG)
    refute_equal(0, r[2].size)
  end
end
