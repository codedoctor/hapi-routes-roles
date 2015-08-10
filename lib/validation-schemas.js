(function() {
  var Joi, i18n, roleId, validateId;

  Joi = require("joi");

  i18n = require("./i18n");

  validateId = Joi.string().length(24);

  roleId = validateId.description(i18n.descriptionRoleId).example(i18n.exampleObjectId);

  module.exports = {
    roleId: roleId
  };

}).call(this);

//# sourceMappingURL=validation-schemas.js.map
