module VagrantPlugins
  module ServiceManager
    class ArchiveHandler
      def executor(file, dest)
        @executor =  case File.extname(file)
                     when '.tgz', '.tar.gz' then TarExecutor.new(file, dest)
                     when '.zip' then ZipExecutor.new(file, dest)
                     end
      end
    end
  end
end
