/*global APP:true, _:true, jQuery:true, Backbone:true, JST:true, $:true*/
/*jslint browser: true, white: false, vars: true, devel: true, bitwise: true, debug: true, nomen: true, sloppy: false, indent: 2*/

(function () {
  "use strict";
  window.APP = window.APP || {Routers: {}, Collections: {}, Models: {}, Views: {}};
  APP.Views.EndpointIndexView = Backbone.View.extend({
    // the constructor
    initialize: function (options) {
      // model is passed through
      this.endpoints = options.endpoints;
      this.endpoints.bind('sync', this.addAll, this);
    },

    // populate the html to the dom
    render: function () {
      this.$el.html($('#endpointsTemplate').html());
      this.addAll();
      return this;
    },

    addAll: function () {
      // clear out the container each time you render index
      var tablebody = this.$el.find('tbody');
      tablebody.children().remove();
      _.each(this.endpoints.models, function(endpoint) {
        var view = new APP.Views.EndpointRowView({endpoint: endpoint});
        tablebody.append(view.render().el);
      });
    }

  });

  APP.Views.EndpointRowView = Backbone.View.extend({
    // the wrapper defaults to div, so only need to set this if you want something else
    // like in this case we are in a table so a tr
    tagName: "tr",

    // the constructor
    initialize: function (options) {
      // model is passed through
      this.endpoint  = options.endpoint;
    },

    // populate the html to the dom
    render: function () {
      this.$el.html(_.template($('#endpointrowTemplate').html(), this.endpoint.toJSON()));
      return this;
    }

  });

}());
