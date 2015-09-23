require 'fileutils'
require 'pathname'
require 'thor'

module Itamae
  module Template
    class CLI < Thor
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
          create(path)
        end
      end

      private

      def create(path)
        relative_path = Pathname.new(path).relative_path_from(TEMPLATE_PATH)
        target_path   = Pathname.new(Dir.pwd).join(relative_path)

        case
        when File.exist?(target_path)
          puts "#{colorize('identical', code: :blue)}  #{relative_path}"
        when File.directory?(path)
          FileUtils.mkdir(target_path)
          puts "#{colorize('create', code: :green)}  #{relative_path}"
        when File.file?(path)
          File.write(target_path, File.read(path))
          puts "#{colorize('create', code: :green)}  #{relative_path}"
        end
      end

      def colorize(text, code: :red)
        "\e[1m\e[#{COLOR_MAP[code]}m#{'%12s' % text}\e[0m"
      end
    end
  end
end
