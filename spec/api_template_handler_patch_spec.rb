require 'spec_helper'

describe Redmine::Views::ApiTemplateHandler do
  it 'is patched with RedmineTags::Patches::ApiTemplateHandlerPatch' do
    patch = RedmineTags::Patches::ApiTemplateHandlerPatch
    expect(Redmine::Views::ApiTemplateHandler.included_modules).to include(patch)
  end
end
