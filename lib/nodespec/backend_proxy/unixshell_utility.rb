require 'shellwords'

module NodeSpec
  module BackendProxy
    module UnixshellUtility
      SUDO_PREFIX = 'sudo'

      def run_as_sudo(cmd)
        "#{SUDO_PREFIX} #{cmd}"
      end

      def cmd_create_directory(path)
        %Q[sh -c "mkdir -p #{path.shellescape}"]
      end

      def cmd_create_file(path, content)
        %Q[sh -c "cat > #{path.shellescape} << EOF\n#{content.strip}\nEOF"]
      end
    end
  end
end