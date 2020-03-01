require "logger"
require "http"
require "uri"

class IsGit
  # Initialize IsGit Class
  def initialize(file : String, output : String, @logger : Logger)
    logger.debug("IsGit initialized ... OK")

    fh = File.read_lines(file) # => ary(String) of lines
    logger.debug("File #{file} imported with total size: #{fh.size} ... OK")

    valid = Array(String).new

    fh.each_with_index do |line, i|
      if is_git(line)
        valid << line # => Add current domain to list of valid results
        @logger.info("Current valid results: #{valid.size} ... ix: #{i} :)")
        write_valid(output, line)
      end
    end
  end

  def write_valid(output : String, domain : String)
    File.open(output, "a") do |file|
      file.puts "#{domain}"
    end
  end

  def do_req(url : String, path : String) : HTTP::Client::Response
    client = HTTP::Client.new(URI.parse("http://#{url}"))
    client.connect_timeout = 5
    res = client.get(path)

    begin
      if res.status_code == 301
        client = HTTP::Client.new(URI.parse("https://#{url}"))
        client.connect_timeout = 5
      end
    rescue
      @logger.debug("Skipping #{url} because of timeout ... :(")
    end

    begin
      res = client.get(path)
    rescue IO::Timeout
      @logger.debug("Skipping #{url} because of timeout ... :(")
    end

    res
  end

  def is_git(domain : String) : Bool
    begin
      @logger.info("Doing vcs//git check on domain ... #{domain}!")
      res = do_req("#{domain}", "/.git/config")
      if res.body.includes?("[core]")
        @logger.info("Found possible .git/config via recon on #{domain} ... Good!")
        return true
      end

      res = do_req("#{domain}", "/.git/HEAD")
      if res.body.includes?("refs/heads")
        @logger.info("Found possible .git/HEAD via recon on #{domain} ... Good!")
        return true
      end
    rescue
      false
    end
    false
  end
end

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

IN_FILE  = "./dns.export.txt"
OUT_FILE = "./dns.git.valid.txt"

isgit = IsGit.new(IN_FILE, OUT_FILE, logger)
