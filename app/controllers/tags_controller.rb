class TagsController < ApplicationController
  before_action :require_admin
  before_action :find_tag, only: [:edit, :update]
  before_action :bulk_find_tags, only: [:context_menu, :merge, :destroy]

  helper :issues_tags

  def edit; end

  def destroy
    @tags.each do |tag|
      # reload raises if tag was already deleted
      tag.reload.destroy rescue nil
    end
    redirect_back_or_default controller: 'settings', action: 'plugin',
      id: 'redmine_tags', tab: 'manage_tags'
  end

  def update
    @tag.update(name: params[:tag][:name])
    if @tag.save
      flash[:notice] = l :notice_successful_update
      respond_to do |format|
        format.html do
          redirect_to controller: 'settings', action: 'plugin',
            id: 'redmine_tags', tab: 'manage_tags'
        end
        format.xml
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
      end
    end
  end

  def context_menu
    @tag = @tags.first if @tags.size == 1
    @back = back_url
    render layout: false
  end

  def merge
    if request.post? && params[:tag] && params[:tag][:name]
      ActsAsTaggableOn::Tagging.transaction do
        tag = ActsAsTaggableOn::Tag.where(name: params[:tag][:name]).first ||
          ActsAsTaggableOn::Tag.create(params[:tag])
        ActsAsTaggableOn::Tagging.where(tag_id: @tags.map(&:id))
          .update_all(tag_id: tag.id)
        @tags.select{|t| t.id != tag.id }.each {|t| t.destroy }
        redirect_to controller: 'settings', action: 'plugin',
          id: 'redmine_tags', tab: 'manage_tags'
      end
    end
  end

  private

  def bulk_find_tags
    @tags = ActsAsTaggableOn::Tag.where(id: params[:id] || params[:ids]).all
    raise ActiveRecord::RecordNotFound if @tags.empty?
  end

  def find_tag
    @tag = ActsAsTaggableOn::Tag.where(id: params[:id]).first or render_404
  end
end
