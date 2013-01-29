RedmineApp::Application.routes.draw do
  match '/issue_tags/auto_complete/:project_id', :to => 'auto_completes#issue_tags', :via => :get, :as => 'auto_complete_issue_tags'
  match '/wiki_tags/auto_complete/:project_id', :to => 'auto_completes#wiki_tags', :via => :get, :as => 'auto_complete_wiki_tags'
end
