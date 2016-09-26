# Redmine Tags

[![Build Status](https://travis-ci.org/ixti/redmine_tags.svg?branch=master)](https://travis-ci.org/ixti/redmine_tags)

Allows marking up different models in Redmine with tags.
Inspired by original `redmine_tags` of Eric Davis.


## Supported models

- Issues
- Wiki pages


## Requirements

Recommended:
- Ruby `2.1.8` or `2.2.4`
- Redmine `3.1.4` or `3.2.1`

While other versions of Ruby `2.x` and Redmine `3.x` are compatible, the
versions above have the advantage of still being maintained.


## Installing

1. Clone this repository into `redmine/plugins/redmine_tags`.
    ```bash
    git clone https://github.com/ixti/redmine_tags.git
    ```

2. Install dependencies and migrate database.
    ```bash
    bundle install
    bundle exec rake redmine:plugins:migrate NAME=redmine_tags RAILS_ENV=production
    ```

3. Restart your Redmine web server.


## Testing

You need to have the
[redmine_testing_gems](https://github.com/ZitecCOM/redmine_testing_gems)
plugin installed.


### Rails

Make sure you have the latest database structure loaded to the test database:
```bash
bundle exec rake db:test:prepare
```

After you cloned the plugin, run the follwing command:
```bash
bundle exec rake redmine:plugins:spec RAILS_ENV=test NAME=redmine_tags
```


### JavaScript

Currently there are no JavaScript tests. But this is how you would run them:

Run this command from the plugin root:
```bash
testem --host 0.0.0.0 --port 9876
```

To run tests in a browser visit `0.0.0.0:9876`.


## Removal

WARNING: This plugin shares the `tags` and `taggings` tables with other plugins
that use the `acts-as-taggable-on` gem. Do not run the below command if you have
another active plugin using them.

```bash
bundle exec rake redmine:plugins:migrate NAME=redmine_tags VERSION=0 FORCE_REDMINE_TAGS_TABLES_REMOVAL=yes
```


## License

This plugin is licensed under the terms of GNU/GPL v3+.
See COPYING and LICENSE for details.
