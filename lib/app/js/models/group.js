(function () {
  "use strict";
  APP.Models.Group = Backbone.Model.extend({
    // you can set any defaults you would like here
    defaults: {
      name: "",
      port: 50000,
      apps: []
    },

    min_port: function() {
      return 50000;
    },

    max_port: function() {
      return 50005;
      return 59999;
    },

    valid_port: function(port) {
      return (_.isNaN(port) || port < this.min_port() || port > this.max_port());
    },

    validate: function (attrs) {
      var errors = {};
      if (attrs.name === '') {
        errors.name = "You need a name.";
      }
      if (_.isNaN(parseInt(attrs.port))) {
        errors.port = "You need a port number.";
      }
      if (parseInt(attrs.port) < 50000 || parseInt(attrs.port) > 59999) {
        errors.port = "The port should be between 50000 and 59999.";
      }
      if (_.isEmpty(attrs.apps)) {
        errors.apps = "Apps list is empty.";
      }

      if (!_.isEmpty(errors)) {
        return errors;
      }
    }

  });

  APP.Collections.Groups = Backbone.Collection.extend({

    url: "/groups",

    // Reference to this collection's model.
    model: APP.Models.Group,

    isValidNew: function (group) {
      var errors = {};
      if (!_.isEmpty(this.where({name: group.get("name")}))) {
        errors.name = "Name <strong>"+group.get("name")+"</strong> already in use.";
      }
      if (!_.isEmpty(this.where({port: group.get("port")}))) {
        errors.port = "Port <strong>"+group.get("port")+"</strong> already in use.";
      }
      if (!_.isEmpty(errors)) {
        group.trigger("invalid", group, errors);
        return false;
      }
      return true;
    },

    commit: function() {
      Backbone.sync('create', this);
    }


  });
}());
