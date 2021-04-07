# Runs automated tests on this repository.
#
# Usage:
# ```bash
# make ci
# ```
.PHONY: ci
ci:
	@rake redmine:plugins:test RAILS_ENV=test NAME=redmine_tags

# Prepares the database.
#
# Usage:
# ```bash
# make prepare
# ```
.PHONY: prepare
prepare:
	@rails db:create db:migrate || true
	@rake db:create db:migrate redmine:plugins:migrate
