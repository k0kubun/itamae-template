# Itamae::Template

Itamae template generator for roles and cookbooks, based on the
[Best Practice](https://github.com/itamae-kitchen/itamae/wiki/Best-Practice)
of [Itamae](https://github.com/itamae-kitchen/itamae/).

## Features

| command | description |
|:-----|:--------|
| `itamae-template init`  | Initialize repository to use cookbooks and roles |
| `itamae-template g role [name]` | Generate roles/[name]/default.rb |
| `itamae-template g cookbook [name]` | Generate cookbooks/[name]/default.rb |
| `itamae-template d role [name]` | Destroy roles/[name]/default.rb |
| `itamae-template d cookbook [name]` | Destroy cookbooks/[name]/default.rb |

And you can include those recipes by `include_cookbook` or `include_role`.

### Capistrano tasks

The initialized repository includes following capistrano tasks.

NOTE: Because `itamae ssh` is slow, itamae-template installs itamae remotely and
execute recipes via `itamae local`.

| command | description |
|:-----|:--------|
| `cap itamae prepare` | Install ruby to execute itamae remotely |
| `cap itamae dry-run` | Check what will be executed |
| `cap itamae apply` | Apply recipes |

## Installation

```bash
$ gem install itamae-template
```

## Get started

This is a tutorial of `itamae-template`.

```bash
# Create repository to add itamae recipes.
$ mkdir infra
$ cd infra
$ git init

# Initialize itamae helpers.
$ gem install itamae-template
$ itamae-template init

# Specify hosts to provision. If you can ssh to the host by `ssh foo`,
# edit: `role :production, %w[foo]`
$ vim config/deploy.rb

# Install ruby and bundler to the production role, i.e. "foo" host.
# It will be installed to /opt/itamae/bin/ruby, not system-widely.
$ bundle install
$ bundle exec cap itamae prepare

# Test execution of the recipes.
$ bundle exec cap itamae dry-run

# Apply recipes. It just prints hello.
$ bundle exec cap itamae apply
```

### Cookbook

```bash
# Drop hello cookbook.
$ itamae-template d cookbook hello

# Create new cookbook. "default.rb" will be loaded by
# `include_cookbook "nginx"`
$ itamae-template g cookbook nginx
$ vim cookbooks/nginx/default.rb
$ vim roles/production/default.rb
```

### Role

```bash
# Create new role.
$ itamae-template g role staging
$ vim roles/staging/default.rb

# Specify hosts to apply staging recipes.
# Edit: `role :staging, %w[bar]`
$ vim config/deploy.rb

# Apply recipes only for staging by the capistrano way.
$ ROLES=staging bundle exec cap itamae apply
```

## License

MIT License
