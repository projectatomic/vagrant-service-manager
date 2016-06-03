require 'rubygems/package'
require 'zlib'

module VagrantPlugins
  module ServiceManager
    class TarHandler
      def initialize(source, dest_binary_path, file_regex)
        @source = source
        @dest_binary_path = dest_binary_path
        @file_regex = file_regex
      end

      def unpack
        Gem::Package::TarReader.new(Zlib::GzipReader.open(@source)) do |tar|
          tar.each do |entry|
            next unless entry.file? && entry.full_name =~ @file_regex

            dest_directory = File.dirname(@dest_binary_path)
            FileUtils.mkdir_p(dest_directory) unless File.directory?(dest_directory)
            File.open(@dest_binary_path, 'wb') { |f| f.print(entry.read) }
          end
        end
      end
    end
  end
end
