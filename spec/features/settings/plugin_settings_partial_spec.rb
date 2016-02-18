require 'spec_helper'

describe 'plugin settings page', type: :feature do
  include LoginSupport
  include SetupSupport

  let(:admin) { create :user, :admin }

  context 'without initial settings' do
    it 'displays without error' do
      clear_plugin_settings

      ui_login_user(admin.login, 'admin')

      visit '/settings/plugin/redmine_tags'

      expect(page).to have_select(
          'settings_issues_sidebar',
          options: ['None', 'List', 'Cloud', 'Simple cloud']
        )
      expect(page).to have_unchecked_field('settings_issues_show_count')
      expect(page).to have_unchecked_field('settings_issues_open_only')
      expect(page).to have_select(
          'settings_issues_sort_by',
          options: ['Name', 'Issues amount']
        )
      expect(page).to have_select(
          'settings_issues_sort_order',
          options: ['Ascending', 'Descending']
        )
      expect(page).to have_unchecked_field('settings_issues_use_colors')
    end
  end

  context 'with initial settings' do
    it 'displays without error' do
      create_initial_settings

      ui_login_user(admin.login, 'admin')

      visit '/settings/plugin/redmine_tags'

      expect(page).to have_select(
          'settings_issues_sidebar',
          selected: @selected_issues_sidebar
        )
      expect(page).to have_checked_field('settings_issues_show_count')
      expect(page).to have_checked_field('settings_issues_open_only')
      expect(page).to have_select(
          'settings_issues_sort_by',
          selected: @selected_issues_sort_by
        )
      expect(page).to have_select(
          'settings_issues_sort_order',
          selected: @selected_issues_sort_order
        )
      expect(page).to have_checked_field('settings_issues_use_colors')
    end
  end
end
