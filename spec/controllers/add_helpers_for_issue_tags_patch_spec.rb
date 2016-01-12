require 'spec_helper'

controllers = [
  IssuesController,
  CalendarsController,
  GanttsController,
  SettingsController
]

controllers.each do |controller|
  describe controller, type: :controller do
    it 'is patched with RedmineTags::Patches::AddHelpersForIssueTagsPatch' do
      patch = RedmineTags::Patches::AddHelpersForIssueTagsPatch
      expect(controller.included_modules).to include(patch)
    end
  end
end
