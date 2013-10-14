RedmineApp::Application.routes.draw do
  match '/issue_tags/auto_complete/:project_id', :to => 'auto_completes#issue_tags', :via => :get, :as => 'auto_complete_issue_tags'
  match '/wiki_tags/auto_complete/:project_id', :to => 'auto_completes#wiki_tags', :via => :get, :as => 'auto_complete_wiki_tags'
  match '/tags/context_menu', :to => 'tags#context_menu', :as => 'tags_context_menu', :via => [:get, :post]
  match '/tags', :controller => 'tags', :action => 'destroy', :via => :delete
end

resources :tags, :only => [:edit, :update] do
  collection do
    post :merge 
    get :context_menu, :merge 
  end  
end
