Redmine Tags
============

Allows marking up different models in Redmine with tags.
Inspired by original redmine\_tags of Eric Davis.

# To make it actually work

Run `rake acts_as_taggable_on_engine:install:migrations`
This will generate some migration files in the redmine /db folder. Remove the
ones already migrated and run 'rake db:migrate'.
If any of them fail just remove them and re-run 'rake db:migrate'.

Supported models
----------------

- Issues
- Wiki pages


Requirements
------------

- Redmine `>= 2.1.0`


Installation
------------

- Clone this repository into `redmine/plugins/redmine_tags`
- Install dependencies and migrate database:

        cd redmine/
        bundle install
        RAILS_ENV=production rake redmine:plugins:migrate

- Restart your Redmine web server (e.g. mongrel, thin, mod\_rails)


License
-------

This plugin is licensed under the terms of GNU/GPL v3+.
See COPYING and LICENSE for details.
