(function () {
  "use strict";
  APP.Models.Endpoint = Backbone.Model.extend({

    defaults: {
      name: "",
      port: "",
      servers: []
    }

  });

  APP.Collections.Endpoints = Backbone.Collection.extend({

    url: '/endpoints',

    model: APP.Models.Endpoint,

    select_multiple: function() {
      var output = "<select multiple class='form-control' name='apps'>";
      _.each(this.models, function(endpoint) {
         output = output + "<option value='"+endpoint.get('name')+"'>"+endpoint.get('name')+"</option>";
      }, this);
      output = output + "</select>";
      return output;
    },

  });


}());
