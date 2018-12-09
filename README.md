# Redmine Tags

[![Build Status](https://travis-ci.org/ixti/redmine_tags.svg?branch=master)](https://travis-ci.org/ixti/redmine_tags)

Allows marking up different models in Redmine with tags.
Inspired by original `redmine_tags` of Eric Davis.

## Important news
**This plugin is EOL** and all my efforts will be pointed to move the current features to the Redmine core. Please see http://www.redmine.org/issues/1448 for more details or to track the progress. I will continue to accept/implement only bug fixes and future Redmine versions.

## Supported models

- Issues
- Wiki pages


## Requirements

- Ruby `>= 2.2.10`
- Redmine `>= 4.0.0`


## Installing

1. Clone this repository into `redmine/plugins/redmine_tags`.

    ```
    cd redmine/plugins
    git clone https://github.com/ixti/redmine_tags.git
    ```

2. Install dependencies and migrate database.

    ```
    bundle install
    rake redmine:plugins:migrate NAME=redmine_tags RAILS_ENV=production
    ```

3. Restart your Redmine web server.


## Running tests

Make sure you have the latest database structure loaded to the test database:

```

rake db:drop db:create db:migrate RAILS_ENV=test
```

After you cloned the plugin, run the following command:

```
rake redmine:plugins:test RAILS_ENV=test NAME=redmine_tags
```


## Removal

WARNING: This plugin shares the `tags` and `taggings` tables with other plugins
that use the `acts-as-taggable-on` gem. Do not run the below command if you have
another active plugin using them.

```
rake redmine:plugins:migrate NAME=redmine_tags VERSION=0 FORCE_REDMINE_TAGS_TABLES_REMOVAL=yes
```


## License

This plugin is licensed under the terms of GNU/GPL v3+.
See COPYING and LICENSE for details.
