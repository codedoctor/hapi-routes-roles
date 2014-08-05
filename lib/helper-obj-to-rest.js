(function() {
  var _;

  _ = require('underscore');

  module.exports = {
    role: function(role, baseUrl) {
      var res;
      if (!role) {
        return null;
      }
      res = {
        _url: "" + baseUrl + "/" + role._id,
        id: role._id,
        name: role.name,
        description: role.description
      };
      return res;
    }
  };

}).call(this);

//# sourceMappingURL=helper-obj-to-rest.js.map
