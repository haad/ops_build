module OpsBuild
  class BoxIndexer
    def initialize(dir:, out:, name:, desc:, root_url:, checksum_type: :sha1)
      @dir           = File.expand_path(dir)
      @out           = out
      @name          = name
      @desc          = desc
      @root_url      = root_url
      @checksum_type = checksum_type

      check_dir!
      check_checksum_type!
    end

    def index
      OpsBuild.logger.debug("Indexing directory '#{@dir}'")
      out = {
          name:        @name,
          description: @desc,
          versions:    []
      }

      Dir.glob("#{@dir}/*.box").each do |path|
        filename = File.basename(path)
        m = /^#{@name}[\_\-](?<version>[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?(\-[0-9]+)?)\.box$/.match(filename)
        next if m.nil?

        OpsBuild.logger.debug("Found box '#{filename}'")

        out[:versions] << box_info(File.expand_path(path), m[:version])
      end

      out
    end

    def index!
      write(index)
    end

    private
    def check_dir!
      raise "Folder '#{@dir}' does not exist!" unless Dir.exists?(@dir)
    end

    def check_checksum_type!
      raise "Unknown checksum type '#{@checksum_type}'!" unless %w(sha1 sha2 md5 rmd160).include?(@checksum_type.to_s.downcase)
    end


    def write(hash)
      File.open(@out, 'w+') { |f| f.write(JSON.pretty_generate(hash)) }
    end
    def box_info(path, version)
      {
          version:   version,
          providers: [{
                          name:          'virtualbox',
                          url:           File.join(@root_url, File.basename(path)),
                          checksum_type: @checksum_type.to_s,
                          checksum:      checksum(path)
                      }]
      }
    end

    def checksum(path)
      Digest.const_get(@checksum_type.upcase).file(path).hexdigest
    end
  end
end