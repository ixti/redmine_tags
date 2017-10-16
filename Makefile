# Runs automated tests on this repository.
#
# Usage:
# ```bash
# make ci
# ```
.PHONY: ci
ci:
	@rake redmine:plugins:test RAILS_ENV=test NAME=redmine_tags
	@rake redmine:plugins:spec RAILS_ENV=test NAME=redmine_tags

# Prepares the database.
#
# Usage:
# ```bash
# make prepare
# ```
.PHONY: prepare
prepare:
	@echo "config.active_record.schema_format = :sql" >> config/additional_environment.rb
	@rake db:create db:migrate redmine:plugins:migrate db:structure:dump
