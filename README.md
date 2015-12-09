# Redmine Tags

Allows marking up different models in Redmine with tags.
Inspired by original `redmine_tags` of Eric Davis.

## Supported models

- Issues
- Wiki pages


## Requirements

- Redmine `>= 3.1.0`


## Install

1. Clone this repository into `redmine/plugins/redmine_tags`

    ```
    cd redmine/plugins
    git clone https://github.com/ixti/redmine_tags.git
    ```

2. Install dependencies and migrate database:

    ```
    bundle install
    rake redmine:plugins:migrate NAME=redmine_tags
    ```

3. Restart your Redmine web server.


## Remove

WARNING: This plugin shares the `tags` and `taggings` tables with other plugins
that use the `acts-as-taggable-on` gem. Do not run the below command if you have
another active plugin using them.

```
rake redmine:plugins:migrate NAME=redmine_tags VERSION=0 ARE_YOU_SURE=yes
```


## License

This plugin is licensed under the terms of GNU/GPL v3+.
See COPYING and LICENSE for details.
