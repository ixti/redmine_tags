class TagsController < ApplicationController
  before_action :require_admin, except: [:add_tag, :delete_tag, :update_tag]
  before_action :require_login, only: [:update_tag]
  before_action :find_tag, only: [:edit, :update]
  before_action :bulk_find_tags, only: [:context_menu, :merge, :destroy]
  before_action :find_project_by_project_id, only: [:add_tag, :delete_tag]

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
    @tag.update_attributes(name: params[:tag][:name])
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

  def add_tag
    @issue_ids = params[:issue_ids]
    @back_url = params[:back_url]
  end

  def delete_tag
    @issue_ids = params[:issue_ids]
    @back_url = params[:back_url]

    issues = Issue.where(id: @issue_ids)
    @candidate_tags = ActsAsTaggableOn::Tag
      .joins(:taggings)
      .where(taggings: {taggable_type: 'Issue', taggable_id: issues})
      .distinct
      .order('tags.name')
  end

  def update_tag
    operate = params[:operate]
    return if operate.blank?

    sabun = params[:tag_list]
    return if sabun.blank?

    sabun = sabun.split(ActsAsTaggableOn.delimiter) unless sabun.is_a?(Array)

    Issue.where(id: params[:issue_ids]).each do |issue|
      old_tags = issue.tag_list.to_s

      case operate
      when 'add'
        issue.tag_list |= sabun
      when 'delete'
        issue.tag_list -= sabun
      end

      new_tags = issue.tag_list.to_s
      unless old_tags == new_tags
        issue.save_tags
        unless issue.current_journal.blank?
          issue.current_journal.details << JournalDetail.new(
            property: 'attr', prop_key: 'tag_list', old_value: old_tags, value: new_tags)
        end
      end
    end
    Issue.remove_unused_tags!
    # redirect_to params[:back_url] if params[:back_url]
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
