task 'apply'   => %w[rsync itamae:bundle_install itamae:apply]
task 'dry-run' => %w[rsync itamae:bundle_install itamae:dry_run]
task 'prepare' => %w[prepare:ruby prepare:bundler]

# Ruby to execute itamae is installed to /opt/itamae.
EMBEDDED_RUBY_DIR = '/opt/itamae'
def bin_path(*paths)
  File.join(EMBEDDED_RUBY_DIR, 'bin', *paths)
end

# This repository is rsynced to /tmp/itamae-cache.
def cache_path(*paths)
  File.join('/tmp/itamae-cache', *paths)
end

task :rsync do
  on roles(:all) do |srv|
    run_locally do
      execute(*%W[
        rsync -az --copy-links --copy-unsafe-links --delete
        --exclude=.git* --exclude=.bundle*
        . #{srv}:#{cache_path}
      ])
    end
  end
end

namespace :itamae do
  def run_itamae(role, dry_run: false)
    local_yaml = File.join(File.expand_path('../../roles', __dir__), role.to_s, 'node.yml')
    sudo(*%W[
      PATH=#{bin_path}:${PATH} BUNDLE_GEMFILE=#{cache_path('Gemfile')}
      #{bin_path('bundle')} exec itamae local
      #{cache_path('recipe_helper.rb')} #{cache_path('roles', role.to_s, 'default.rb')}
      --no-color #{'--dry-run' if dry_run}
      #{"--node-yaml=#{cache_path('roles', role.to_s, 'node.yml')}" if File.exist?(local_yaml)}
    ])
  end

  task :bundle_install do
    on roles(:all) do
      sudo(*%W[
        BUNDLE_GEMFILE=#{cache_path('Gemfile')}
        #{bin_path('bundle')} install --jobs `nproc` --without local --quiet
      ])
    end
  end

  task :dry_run do
    on roles(:all) do |srv|
      srv.roles.each do |role|
        run_itamae(role, dry_run: true)
      end
    end
  end

  task :apply do
    on roles(:all) do |srv|
      srv.roles.each do |role|
        run_itamae(role)
      end
    end
  end
end

namespace :prepare do
  task :ruby do
    on roles(:all) do
      def install_ruby(platform, version)
        return if capture("test -e #{bin_path('ruby')}; echo $?") == '0'

        sudo :mkdir, '-p', EMBEDDED_RUBY_DIR
        begin
          cache_url = "https://s3.amazonaws.com/pkgr-buildpack-ruby/current/#{platform}/ruby-#{version}.tgz"
          sudo(*%W[curl -s #{cache_url} -o /tmp/ruby.tgz])
        rescue SSHKit::Command::Failed
          # TODO: build ruby with ruby-build.
          abort "'#{platform}' is not supported now. Please update config/deploy/itamae.rb"
        end
        sudo(*%W[tar xzf /tmp/ruby.tgz -C #{EMBEDDED_RUBY_DIR}])
      end

      # FIXME: support more OSs or versions. Basically this is using:
      # http://blog.packager.io/post/101342252191/one-liner-to-get-a-precompiled-ruby-on-your-own
      os = capture('head -n1 /etc/issue')
      case os
      when /^Ubuntu/
        install_ruby('ubuntu-14.04', '2.1.4')
      when /^CentOS release (\d)/
        install_ruby("centos-#{$1}", '2.1.4')
      when /Red Hat Enterprise Linux/
        install_ruby('centos-6', '2.1.4')
      when /Debian/
        install_ruby('debian-7', '2.1.4')
      when /Fedora/
        install_ruby('fedora-20', '2.1.4')
      else
        abort "'#{os}' is not supported now. Please update config/deploy/itamae.rb"
      end
    end
  end

  task :bundler do
    on roles(:all) do
      execute!(*%W[test -e #{bin_path('bundle')} || sudo #{bin_path('gem')} install bundler --no-ri --no-rdoc])
    end
  end
end
