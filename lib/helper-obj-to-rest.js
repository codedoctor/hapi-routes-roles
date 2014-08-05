(function() {
  var _;

  _ = require('underscore');

  module.exports = {
    role: function(role, baseUrl, isInAdminScope) {
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
      if (isInAdminScope) {
        res.accountId = role.accountId;
        res.isInternal = role.isInternal;
      }
      return res;
    }
  };

}).call(this);

//# sourceMappingURL=helper-obj-to-rest.js.map
