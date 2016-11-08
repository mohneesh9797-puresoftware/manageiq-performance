require "yaml"
require "fileutils"
require "miq_performance/configuration"

module MiqPerformance
  module MiddlewareStorage
    class File
      attr_reader :miq_performance_suite_dir

      def initialize
        create_suite_dir
      end

      def record filename, _, file_data
        write_report_file filename, &file_data
      end

      # noop:  Files have already been written at this point
      def finalize; end

      private

      def create_suite_dir
        base_dir = MiqPerformance.config.default_dir
        suite_dir = ::File.join(base_dir, "run_#{Time.now.to_i}")
        FileUtils.mkdir_p(suite_dir)

        @miq_performance_suite_dir = suite_dir
      end

      def write_report_file filename
        filepath = ::File.join(miq_performance_suite_dir, filename)
        FileUtils.mkdir_p(::File.dirname filepath)
        ::File.open(filepath, 'wb') do |file_io|
          data = yield
          file_io.write data.is_a?(Hash) ? data.to_yaml : data
        end
        filename
      end
    end
  end
end