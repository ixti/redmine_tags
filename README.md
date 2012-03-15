Redmine Tags
============

Allows marking up different models in Redmine with tags.
Inspired by original redmine_tags of Eric Davis.


Supported models
----------------

- Issues


Requirements
------------

- Redmine `>= 1.2.0`
- acts-as-taggable-on `= 2.1.0`


Installation
------------

- Follow the [Redmine plugin installation][installation-docs] steps and make
  sure the plugin is installed to `vendor/plugins/redmine_tags`
- Install `acts-as-taggable-on`
  - Run migration generator: `script/generate acts_as_taggable_on_migration`
  - Run migration: `rake db:migrate`
- Restart your Redmine web servers (e.g. mongrel, thin, mod\_rails)


Migrating from 1.x to 2.x
-------------------------

As of 2.0.0 redmine\_tags is not compatible with 1.x branch.

So the easiest way to install redmine\_tags 2.x is to completely uninstall
previously installed redmine\_tags 1.x first and then installing new version.
Alternatively you can "fix" migration names in the database, but that requires
some skills and understanding of are you doing. If you are brave enough,
follow the steps below.

**NOTICE** I take no reponsibility for any possible data loss.

Since version 2.0.0 redmine\_tags do not provides database migration for
`acts-as-taggable-on` plugin. So in order to migrate properly you will need to
make that migration as if it was installed to the main rails application.

First of all, move the migration script from plugin to main app:

```
$ cp ./vendor/plugins/redmine_tags/db/migrate/001_acts_as_taggable_on_migration.rb \
     ./db/migrate/20120101000000_acts_as_taggable_on_migration.rb
```

Make sure to change `001_` prefix to `20120101000000_`.
Now connect to your database and replace `redmine_tags` schema migration entry
with just created one:

``` SQL
DELETE FROM `schema_migrations` WHERE `version` = '1-redmine_tags';
INSERT INTO `schema_migrations` (`version`) VALUES ('20120101000000');
```

That's all. :))


License
-------

This plugin is licensed under the terms of GNU/GPL v3+.
See COPYING and LICENSE for details.


[installation-docs]: www.redmine.org/wiki/redmine/Plugins
