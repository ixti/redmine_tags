module RedmineTags
  module Patches
    module WikiControllerPatch
      def self.included(base)
        base.send :helper, 'tags'
        base.send :helper, 'wiki_tags'
      end
    end
  end
end
