module Vnspec
  module Config
    DEFAULT_CONFIG = {
      vnet_path: "/opt/axsh/openvnet",
      vnet_branch: "master",
      update_vnet_via: "rsync",
      ssh_user: "root",
      exit_on_error: true,
      test_ready_check_interval: 10,
      test_retry_count: 30,
      log_level: :info,
    }

    class << self
      def config
        unless @config
          env = ENV["VNSPEC_ENV"] || "dev"
          @config = DEFAULT_CONFIG.dup
          @config[:env] = env
          ["base", env].each do |n|
            file = File.expand_path("../../config/#{n}.yml", File.dirname(__FILE__))
            @config.merge!(YAML.load_file(file).symbolize_keys)
          end
        end
        @config
      end
    end

    def config
      Config.config
    end
  end
end
