# Load DSL and set up stages
require 'capistrano/setup'

# Enable sudo
require 'sshkit/sudo'

# You can send password with $SUDO_PASSWORD
if ENV['SUDO_PASSWORD']
  module SSHKit
    def Sudo.password_cache
      Hash.new { "#{ENV['SUDO_PASSWORD']}\n" }
    end
  end
end
