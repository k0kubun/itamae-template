task 'apply'   => %w[rsync itamae:bundle_install itamae:apply]
task 'dry-run' => %w[rsync itamae:bundle_install itamae:dry_run]
task 'prepare' => %w[prepare:ruby prepare:bundler]

EMBEDDED_RUBY_DIR = '/opt/itamae'
def bin_path(name)
  File.join(EMBEDDED_RUBY_DIR, 'bin', name)
end

task :rsync do
  on roles(:all) do |srv|
    run_locally do
      execute "rsync -az --copy-links --copy-unsafe-links --delete --exclude=.git* --exclude=.bundle* . #{srv}:/tmp/itamae-cache"
    end
  end
end

namespace :itamae do
  def run_itamae(role, dry_run: false)
    recipe_path = File.join('/tmp/itamae-cache/roles', role.to_s, 'default.rb')
    sudo(*%W[
      PATH=#{File.join(EMBEDDED_RUBY_DIR, 'bin')}:${PATH} BUNDLE_GEMFILE=/tmp/itamae-cache/Gemfile
      #{bin_path('bundle')} exec itamae local /tmp/itamae-cache/recipe_helper.rb #{recipe_path}
      --no-color #{'--dry-run' if dry_run}
    ])
  end

  task :bundle_install do
    on roles(:all) do
      sudo(*%W[
        BUNDLE_GEMFILE=/tmp/itamae-cache/Gemfile
        #{bin_path('bundle')} install --jobs `nproc` --without cap --quiet
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
