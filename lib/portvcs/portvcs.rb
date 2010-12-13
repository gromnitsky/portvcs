require 'socket'

# :include: ../../README.rdoc
module PortVCS
  
  # A wrapper for *Dumb classes
  class VCS
    
    def self.select(type)
      case type
      when 'cvs'
        return CVSDumb
      else
        fail "unknown VCS '#{type}'"
      end
    end
    
    # sys -- a class like CVSDumb
    def initialize(sys)
      @sys = VCS.select(sys)
    end

    attr_accessor :sys

    def open(p)
      s1 = s2 = @sys.new(p)
      if block_given?
        begin
          s1 = yield(s2)
        rescue
          fail $!
        ensure
          s2.close
        end
      end
      
      return s1
    end
    
  end # VCS

  class CVSDumb
    # debug print prefixes
    CLIENT = 'C: '
    SERVER = 'S: '

    PASSPAIR = {
      ?! => 120, ?" => 53, ?% => 109, ?& => 72, ?' => 108, ?( => 70, ?) => 64,
      ?* => 76, ?+ => 67, ?, => 116, ?- => 74, ?. => 68, ?/ => 87, ?0 => 111,
      ?1 => 52, ?2 => 75, ?3 => 119, ?4 => 49, ?5 => 34, ?6 => 82, ?7 => 81,
      ?8 => 95, ?9 => 65, ?: => 112, ?; => 86, ?< => 118, ?= => 110, ?> => 122,
      ?? => 105, ?A => 57, ?B => 83, ?C => 43, ?D => 46, ?E => 102, ?F => 40,
      ?G => 89, ?H => 38, ?I => 103, ?J => 45, ?K => 50, ?L => 42, ?M => 123,
      ?N => 91, ?O => 35, ?P => 125, ?Q => 55, ?R => 54, ?S => 66, ?T => 124,
      ?U => 126, ?V => 59, ?W => 47, ?X => 92, ?Y => 71, ?Z => 115, ?_ => 56,
      ?a => 121, ?b => 117, ?c => 104, ?d => 101, ?e => 100, ?f => 69, ?g => 73,
      ?f => 69, ?h => 99, ?i => 63, ?j => 94, ?k => 93, ?l => 39, ?m => 37,
      ?n => 61, ?o => 48, ?p => 58, ?q => 113, ?r => 32, ?s => 90, ?t => 44,
      ?u => 98, ?v => 60, ?w => 51, ?x => 33, ?y => 97, ?z => 62
    }

    def self.pass_scramble(t)
      r = ?A
      t.each_char {|i|
        fail "invalid char in pass: #{i}" if ! PASSPAIR.key? i
        r << PASSPAIR[i].chr
      }
      return r
    end

    # the algorithm is symmetric
    def self.pass_descramble(t)
      pass_scramble(t)[2..-1]
    end

    # p is a hash
    def initialize(p)
      @host = p[:host]
      @port = p[:port]
      @user = p[:user]
      @pass = p[:pass]
      @cvsroot = p[:cvsroot].strip
      @debug = p[:debug]
      @ports_tree = p[:ports_tree].strip

      @client = TCPSocket.open(@host, @port)
      request("BEGIN AUTH REQUEST")
      request(@cvsroot)
      request(@user)
      request(CVSDumb.pass_scramble(@pass))
      request("END AUTH REQUEST")
      fail "cannot auth to #{@user}@#{@host}" if getline != 'I LOVE YOU'
    end

    attr_accessor :debug

    def version
      request('version')
      request('noop')
      r = getline_text
      getline # for 'noop'
      return r
    end

    def log(dir, file = nil, date_cond = nil)
      request("Root #{@cvsroot}")
      request("Directory .")
      request("#{@cvsroot}/#{@ports_tree.to_s == '' ? '' : @ports_tree + '/'}#{dir}")
      request("Argument -N")
      if date_cond
        request("Argument -d")
        request("Argument #{date_cond}")
      end
      request("Argument #{file}") if file != nil
      request('log')

      getmultilines_text {|i| yield i }
    end
    
    def close
      @client.close
    end

    
    protected
    
    # debug print
    def dputs(type, t)
      puts "#{type}#{t}" if debug
    end

    def getline
      r = @client.gets.strip
      dputs(SERVER, r)
      return r
    end

    def getline_text
      @client
      r = getline
      if r.match(/^M (.+)/)
        getline # read final 'ok\n'
        return $1
      else
        fail "protocol error (unexpected string): #{r}"
      end
    end

    def getmultilines_text
      is_error = false
      e = []
      while line = @client.gets.strip
        break if line == 'ok'
        if line == 'error'
          is_error = true
          break
        end

        if (line =~ /^(M|E) ?(.*)/)
          if $1 == 'E'
            e << $2
          else
            yield $2
          end
        else
          fail "protocol error (unexpected string): #{line}"
        end
      end

      fail "protocol error: " + e.join(', ') if is_error
    end

    def request(t)
      @client.send("#{t}\n", 0)
      dputs(CLIENT, t)
    end
    
  end # CVSDumb

end # module
