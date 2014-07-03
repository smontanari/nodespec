require 'shellwords'

module NodeSpec
  module BackendProxy
    module UnixshellUtility
      SUDO_PREFIX = 'sudo'
      TEMP_DIR = '/tmp'

      def run_as_sudo(cmd)
        "#{SUDO_PREFIX} #{cmd}"
      end

      def cmd_create_directory(path)
        shellcmd("mkdir -p #{path.shellescape}")
      end

      def cmd_create_file(path, content)
        shellcmd("cat > #{path.shellescape} << EOF\n#{content.strip.gsub('"', '\"')}\nEOF")
      end

      def temp_directory
        TEMP_DIR
      end

      private

      def shellcmd(cmd)
        %Q[sh -c "#{cmd}"]
      end
    end
  end
end