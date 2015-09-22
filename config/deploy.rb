# Configure hosts to apply recipes. You can filter roles by ROLES env variable.
# ex) ROLES=role1,role2 bundle exec cap itamae apply
role :production, %w[example-host.com]

# Capistrano uses /tmp/cap-itamae temporarily.
set :application, 'cap-itamae'

# Deploy this repository to /tmp/itamae-cache. Because `itamae local` is fater
# than `itamae ssh`, this script deploys itamae recipes to the remote hosts.
set :deploy_to, '/tmp/itamae-cache'

# Deploy this repository using capistrano-rsync plugin.
set :scm, :rsync
set :repo_url, '.'
set :rsync_options, %w[--recursive --delete --delete-excluded .git*]
