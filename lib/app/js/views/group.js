/*global APP:true, _:true, jQuery:true, Backbone:true, JST:true, $:true*/
/*jslint browser: true, white: false, vars: true, devel: true, bitwise: true, debug: true, nomen: true, sloppy: false, indent: 2*/

(function () {
  "use strict";
  window.APP = window.APP || {Routers: {}, Collections: {}, Models: {}, Views: {}};
  APP.Views.GroupIndexView = Backbone.View.extend({
    // the constructor
    initialize: function (options) {
      // model is passed through
      this.groups = options.groups;
      this.groups.bind('sync', this.addAll, this);
    },

    // populate the html to the dom
    render: function () {
      this.$el.html($('#indexTemplate').html());
      this.addAll();
      return this;
    },

    addAll: function () {
      // clear out the container each time you render index
      this.$el.find('tbody').children().remove();
      _.each(this.groups.models, $.proxy(this, 'addOne'));
    },

    addOne: function (group) {
      var view = new APP.Views.GroupRowView({groups: this.groups, group: group});
      this.$el.find("tbody").append(view.render().el);
    }
  });

  APP.Views.GroupRowView = Backbone.View.extend({
    // the wrapper defaults to div, so only need to set this if you want something else
    // like in this case we are in a table so a tr
    tagName: "tr",
    // functions to fire on events
    events: {
      "click a.delete": "destroy"
    },

    // the constructor
    initialize: function (options) {
      // model is passed through
      this.group  = options.group;
      this.groups = options.groups;
    },

    // populate the html to the dom
    render: function () {
      this.$el.html(_.template($('#rowTemplate').html(), this.group.toJSON()));
      return this;
    },

    // delete the model
    destroy: function (event) {
      event.preventDefault();
      event.stopPropagation();
      // we would call
      // this.model.destroy();
      // which would make a DELETE call to the server with the id of the item
      this.groups.remove(this.group);
      this.$el.remove();
    }
  });

  APP.Views.GroupNewView = Backbone.View.extend({
    // functions to fire on events
    events: {
      "click button.save": "save",
      "click button#upbutton": "up",
      "click button#downbutton": "down"
    },

    // the constructor
    initialize: function (options) {
      this.group  = options.group;
      this.groups = options.groups;
      this.group.bind('invalid', this.showErrors, this);
    },

    up: function(event) {
      event.stopPropagation();
      event.preventDefault();
      var current_value = parseInt(this.$el.find('input[name=port]').val());
      if (this.group.valid_port(current_value)) {
        this.$el.find('input[name=port]').val(this.group.max_port());
        current_value = this.group.max_port();
      }
      if (current_value < this.group.max_port()) {
        this.$el.find('input[name=port]').val(current_value + 1);
      }
    },

    down: function(event) {
      event.stopPropagation();
      event.preventDefault();
      var current_value = parseInt(this.$el.find('input[name=port]').val());
      if (this.group.valid_port(current_value)) {
        this.$el.find('input[name=port]').val(this.group.min_port());
        current_value = this.group.min_port();
      }
      if (current_value > this.group.min_port()) {
        this.$el.find('input[name=port]').val(current_value - 1);
      }
    },

    showErrors: function (group, errors) {
      this.$el.find('.error').removeClass('error');
      this.$el.find('.alert').html(_.values(errors).join('<br>')).show();
      // highlight the fields with errors
      _.each(_.keys(errors), _.bind(function (key) {
        this.$el.find('*[name=' + key + ']').parent().addClass('error');
      }, this));
    },

    save: function (event) {
      event.stopPropagation();
      event.preventDefault();

      // update our model with values from the form
      this.group.set({
        name: this.$el.find('input[name=name]').val(),
        port: parseInt(this.$el.find('input[name=port]').val()),
        apps: this.$el.find("option:selected").map(function(){ return this.value }).get(),
      });

      if (this.group.isValid() && this.groups.isValidNew(this.group)) {
        // add it to the collection
        this.groups.add(this.group);
        // this.note.save();
        // redirect back to the index
        window.location.hash = "groups/index";
      }
    },

    // populate the html to the dom
    render: function () {
      var group_multiselect = _.extend(this.group.toJSON(), {endpoints_select: VAR.endpoints.select_multiple()});
      this.$el.html(_.template($('#formTemplate').html(), group_multiselect));
      this.$el.find('h2').text('Create New Group');
      return this;
    }
  });

  APP.Views.GroupEditView = Backbone.View.extend({
    // functions to fire on events
    events: {
      "click button.save": "save"
    },

    // the constructor
    initialize: function (options) {
      this.group  = options.group;
      this.group.bind('invalid', this.showErrors, this);
    },

    showErrors: function (group, errors) {
      this.$el.find('.error').removeClass('error');
      this.$el.find('.alert').html(_.values(errors).join('<br>')).show();
      // highlight the fields with errors
      _.each(_.keys(errors), _.bind(function (key) {
        this.$el.find('*[name=' + key + ']').parent().addClass('error');
      }, this));
    },

    save: function (event) {
      event.stopPropagation();
      event.preventDefault();

      // update our model with values from the form
      this.group.set({
        name: this.$el.find('input[name=name]').val(),
        port: this.$el.find('input[name=port]').val(),
        apps: this.$el.find("option:selected").map(function(){ return this.value }).get(),
      });

      if (this.group.isValid()){
        // add it to the collection
        // this.note.save();
        // redirect back to the index
        window.location.hash = "groups/index";
      }
    },

    // populate the html to the dom
    render: function () {
      var group_multiselect = _.extend(this.group.toJSON(), {endpoints_select: VAR.endpoints.select_multiple()});
      this.$el.html(_.template($('#formTemplate').html(), group_multiselect));
      this.$el.find('h2').text('Edit Group');
      return this;
    }
  });

}());
