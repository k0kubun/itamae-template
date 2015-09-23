require 'fileutils'
require 'pathname'
require 'thor'

module Itamae
  module Template
    class CLI < Thor
      AVAILABLE_TARGETS = %w[role cookbook].freeze
      TEMPLATE_PATH = Pathname.new(File.expand_path('../../../template', __dir__))
      COLOR_MAP = {
        red:   31, # remove
        green: 32, # create
        blue:  34, # identical
        white: 37, # invoke
      }

      desc 'init', 'Initialize itamae repository'
      def init
        Dir.glob(TEMPLATE_PATH.join('**/*')).sort.each do |path|
          copy_template(path)
        end
      end

      desc 'generate [role|cookbook] [NAME]', 'Generate role or cookbook'
      def generate(target, name)
        validate_target!(target)

        create_directory(File.join("#{target}s", name))
        create_file(File.join("#{target}s", name, 'default.rb'), "# noop\n")
        if target == 'role'
          create_file(File.join("#{target}s", name, 'node.yml'), "# No variables\n")
        end
      end
      method_option :generate, aliases: :g

      desc 'destroy [role|cookbook] [NAME]', 'Destroy role or cookbook'
      def destroy(target, name)
        validate_target!(target)

        recursive_remove(File.join("#{target}s", name))
        recursive_remove(File.join("#{target}s", name, 'default.rb'))
        if target == 'role'
          recursive_remove(File.join("#{target}s", name, 'node.yml'))
        end
      end
      method_option :destroy, aliases: :d

      private

      def validate_target!(target)
        unless AVAILABLE_TARGETS.include?(target)
          abort "Unexpected target '#{target}' is given.\n  Allowed: #{AVAILABLE_TARGETS.join(', ')}"
        end
      end

      def copy_template(path)
        relative_path = Pathname.new(path).relative_path_from(TEMPLATE_PATH)

        if File.file?(path)
          create_file(relative_path, File.read(path))
        else
          create_directory(relative_path)
        end
      end

      def create_file(relative_path, content)
        target_path = Pathname.new(Dir.pwd).join(relative_path)

        if File.exist?(target_path)
          puts "#{colorize('identical', code: :blue)}  #{relative_path}"
        else
          File.write(target_path, content)
          puts "#{colorize('create', code: :green)}  #{relative_path}"
        end
      end

      def create_directory(relative_path)
        target_path = Pathname.new(Dir.pwd).join(relative_path)

        if File.exist?(target_path)
          puts "#{colorize('identical', code: :blue)}  #{relative_path}"
        else
          FileUtils.mkdir(target_path)
          puts "#{colorize('create', code: :green)}  #{relative_path}"
        end
      end

      def recursive_remove(relative_path)
        target_path = Pathname.new(Dir.pwd).join(relative_path)
        FileUtils.rm_rf(target_path)
        puts "#{colorize('remove', code: :red)}  #{relative_path}"
      end

      def colorize(text, code: :red)
        "\e[1m\e[#{COLOR_MAP[code]}m#{'%12s' % text}\e[0m"
      end
    end
  end
end
