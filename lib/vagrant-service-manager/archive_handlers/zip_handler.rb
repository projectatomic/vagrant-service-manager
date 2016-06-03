require 'zip'

module VagrantPlugins
  module ServiceManager
    class ZipHandler
      def initialize(source, dest_binary_path, file_regex)
        @source = source
        @dest_binary_path = dest_binary_path
        @file_regex = file_regex
      end

      def unpack
        Zip::File.open(@source) do |zipfile|
          zipfile.each do |entry|
            next unless entry.ftype == :file && entry.name =~ @file_regex

            dest_directory = File.dirname(@dest_binary_path)
            FileUtils.mkdir_p(dest_directory) unless File.directory?(dest_directory)
            zipfile.extract(entry, @dest_binary_path)
          end
        end
      end
    end
  end
end
