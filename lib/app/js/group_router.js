(function () {
  "use strict";
  window.APP = window.APP || {Routers: {}, Collections: {}, Models: {}, Views: {}};
  APP.Routers.Groups = Backbone.Router.extend({
    routes: {
      "groups/new": "create",
      "groups/save": "save",
      "groups/index": "index",
      "groups/:name/edit": "edit"
    },

    initialize: function (options) {
      this.groups    = options.groups;
      this.endpoints = options.endpoints;
      // this is debug only to demonstrate how the backbone collection / models work
      // this.groups.bind('reset',  this.updateDebug, this);
      // this.groups.bind('add',    this.updateDebug, this);
      // this.groups.bind('remove', this.updateDebug, this);
      this.index();
    },

    updateDebug: function () {
      $('#output').text(JSON.stringify(this.groups.toJSON(), null, 4));
    },

    create: function () {
      this.currentView = new APP.Views.GroupNewView({groups: this.groups, group: new APP.Models.Group()});
      $('#groups-content').html(this.currentView.render().el);
      $('#endpoints-content').hide();
    },

    save: function () {
      VAR.groups.commit();
      $('#spinner').show();
      setInterval(function() { $('#spinner').hide();}, 2000);
    },

    edit: function (name) {
      var group = this.groups.where({name:name})[0];
      this.currentView = new APP.Views.GroupEditView({group: group});
      $('#groups-content').html(this.currentView.render().el);
      $('#endpoints-content').hide();
    },

    index: function () {
      this.currentView   = new APP.Views.GroupIndexView({groups: this.groups});
      this.endpointsView = new APP.Views.EndpointIndexView({endpoints: this.endpoints});
      $('#groups-content').html(this.currentView.render().el);
      $('#endpoints-content').html(this.endpointsView.render().el);
      $('#endpoints-content').show();
    }
  });
}());
