require 'yaml'
require 'pp'
require_relative 'meta'

module PortVCS

  class Utils
    
    # load config file immediately if it contains '/' in its name,
    # otherwise search through several dirs for it.
    #
    # conf -- a hash to merge result with
    #
    # return a loaded filename or nil on error
    def self.config_load(conf, file, dirs)
      p = ->(f) {
        if File.readable?(f)
          begin
            myconf = YAML.load_file(f)
          rescue
            abort("cannot parse #{f}: #{$!}")
          end
          %w(host port user pass cvsroot ports_tree).each { |i|
            fail "missing or nil '#{i}' in #{f}" if ! myconf.key?(i.to_sym) || ! myconf[i.to_sym]
          }
          conf.merge!(myconf)
          return file
        end
        return nil
      }

      if file.index('/')
        return p.call(file)
      else
        dirs.each {|dir| return dir+'/'+file if p.call(dir + '/' + file) }
      end

      return nil
    end

    # p -- a string to examine
    # ptree -- a directory name with a local port tree, for example "/usr/ports"
    def self.port_extract_name(t, ptree)
      return nil if t.to_s == '' || (! t.index('/') && Dir.pwd !~ /^#{ptree}/)

      t.sub!(/#{ptree}(\/*)?/, '') if t =~ /^#{ptree}/
      return nil if t[0] == '/'

      # idempotent lambda
      inptree = ->() {
        if Dir.pwd =~ /^#{ptree}/
          l = (d = Dir.pwd.sub(/#{ptree}(\/*)?/, '')).split('/').length
          return File.split(d + '/' + t) if l >= 2 && l <= 3
        end
      }
      
      case t.split('/').length
      when 1
        return inptree.call
      when 2
        # assuming files/patch-aa in /usr/ports/www/firefox/files/
        return inptree.call if inptree.call
        # assuming www/firefox
        return [t]
      when 3..4
        # assuming www/firefox/Makefile
        return File.split(t)
      end

      return nil
    end

    def self.gem_libdir
      t = ["#{File.dirname(File.expand_path($0))}/../lib/#{PortVCS::Meta::NAME}",
           "#{Gem.dir}/gems/#{PortVCS::Meta::NAME}-#{PortVCS::Meta::VERSION}/lib/#{PortVCS::Meta::NAME}"]
      t.each {|i| return i if File.readable?(i) }
      fail "both paths are invalid: #{t}"
    end

    def self.in_path?(file)
      return true if file =~ %r%\A/% and File.exist? file

      ENV['PATH'].split(File::PATH_SEPARATOR).any? do |path|
        File.exist? File.join(path, file)
      end
    end
    
  end # Utils
end
