require 'spec_helper'

describe QueriesHelper, type: :model do
  it 'is patched with RedmineTags::Patches::QueriesHelperPatch' do
    patch = RedmineTags::Patches::QueriesHelperPatch
    expect(QueriesHelper.included_modules).to include(patch)
  end
end
