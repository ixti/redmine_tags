Redmine Tags
============

Allows marking up different models in Redmine with tags.
Inspired by original redmine\_tags of Eric Davis.


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

