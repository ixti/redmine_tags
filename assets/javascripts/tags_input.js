/**
 * This file is a part of redmine_tags
 * redMine plugin, that adds tagging support.
 *
 * Copyright (c) 2010 Aleksey V Zapparov AKA ixti
 *
 * redmine_tags is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * redmine_tags is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with redmine_tags.  If not, see <http://www.gnu.org/licenses/>.
 */

var Redmine = Redmine || {};

Redmine.TagsInput = Class.create({
  initialize: function(element) {
    this.element  = $(element);
    this.input    = new Element('input', { 'type': 'text', 'autocomplete': 'off', 'size': 10 });
    this.button   = new Element('span', { 'class': 'tag-add icon icon-add' });
    this.tags     = new Hash();
    
    Event.observe(this.button, 'click', this.readTags.bind(this));
    Event.observe(this.input, 'keypress', this.onKeyPress.bindAsEventListener(this));

    this.element.insert({ 'after': this.input });
    this.input.insert({ 'after': this.button });
    this.addTagsList(this.element.value);
  },

  readTags: function() {
    this.addTagsList(this.input.value);
    this.input.value = '';
  },

  onKeyPress: function(event) {
    if (Event.KEY_RETURN == event.keyCode) {
      this.readTags(event);
      Event.stop(event);
    }
  },

  addTag: function(tag) {
    if (tag.blank() || this.tags.get(tag)) return;

    var button = new Element('span', { 'class': 'tag-delete icon icon-del' });
    var label  = new Element('span', { 'class': 'tag-label' }).insert(tag).insert(button);

    this.tags.set(tag, 1);
    this.element.value = this.getTagsList();
    this.element.insert({ 'before': label });

    Event.observe(button, 'click', function(){
      this.tags.unset(tag);
      this.element.value = this.getTagsList();
      label.remove();
    }.bind(this));
  },

  addTagsList: function(tags_list) {
    var tags = tags_list.split(',');
    for (var i = 0; i < tags.length; i++) {
      this.addTag(tags[i].strip());
    }
  },

  getTagsList: function() {
    return this.tags.keys().join(',');
  },

  autocomplete: function(container, url) {
    new Ajax.Autocompleter(this.input, container, url, {
      'minChars': 1,
      'frequency': 0.5,
      'paramName': 'q',
      'updateElement': function(el) {
        this.input.value = el.getAttribute('name');
        this.readTags();
      }.bind(this)
    });
  }
});


function observeIssueTagsField(url) {
  new Redmine.TagsInput('issue_tag_list').autocomplete('issue_tag_candidates', url);
}
