# You can filter roles by ROLES env variable.
#   $ ROLES=role1,role2 bundle exec cap itamae apply
#
# With following example, you can apply recipes to production role by:
#   $ ROLES=production bundle exec cap itamae apply
#
# TODO: Configure hosts to apply recipes.
role :production, %w[example-host.com]
