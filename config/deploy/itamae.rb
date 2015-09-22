task apply: %w[rsync itamae:bundle_install itamae:apply]
task prepare: %w[prepare:ruby prepare:bundler]

task :rsync do
  on roles(:all) do |srv|
    run_locally do
      execute "rsync -az --copy-links --copy-unsafe-links --delete --exclude=.git* . #{srv}:/tmp/itamae-cache"
    end
  end
end

namespace :itamae do
  task :bundle_install do
    on roles(:all) do
      execute('cd /tmp/itamae-cache && (~/.itamae/bin/bundle check || ~/.itamae/bin/bundle install --jobs `nproc`)')
    end
  end

  task :apply do
    on roles(:all) do |srv|
      srv.roles.each do |role|
        puts role
      end
    end
  end
end

namespace :prepare do
  task :ruby do
    on roles(:all) do
      # Installing embedded ruby to ~/.itamae because it's hard to install under
      # /opt using capistrano 3, which does not support sudo with password.
      def install_ruby(platform, version)
        execute("test -e ~/.itamae || (mkdir ~/.itamae && curl -s https://s3.amazonaws.com/pkgr-buildpack-ruby/current/#{platform}/ruby-#{version}.tgz -o - | tar xzf - -C ~/.itamae)")
      end

      # FIXME: support more OSs or versions. Basically this is using:
      # http://blog.packager.io/post/101342252191/one-liner-to-get-a-precompiled-ruby-on-your-own
      os = capture('head -n1 /etc/issue')
      case os
      when /^Ubuntu/
        install_ruby('ubuntu-14.04', '2.1.4')
      when /^CentOS/
        install_ruby('centos-6', '2.1.4')
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
      execute('test -e ~/.itamae/bin/bundle || ~/.itamae/bin/gem install bundler --no-ri --no-rdoc')
    end
  end
end
