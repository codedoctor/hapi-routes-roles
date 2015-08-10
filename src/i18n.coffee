
###
Human readable messages used in the plugin.
###
module.exports = 
  ###
  Do not translate
  ###
  optionsAccountIdRequired : "options parameter requires a '_tenantId'"
  optionsBaseUrlRequired: "options parameter requires a 'baseUrl' (http://api.mysite.com , http://localhost:4321)"
  optionsRoutesBaseNameRequired: "options parameter requires a 'routesBaseName' (roles)"
  optionsServerAdminScopeNameRequired: "options parameter requires a 'serverAdminScopeName' (server-admin)"
  optionsRouteTagsPublicRequiredAndArray: "options parameter requires a 'routesTagsPublic' field that is an array."
  optionsDescriptionGetAllRequired: "options parameter requires a 'descriptionGetAll' field."
  optionsDescriptionPostRequired: "options parameter requires a 'descriptionPost' field."
  optionsDescriptionGetOneRequired: "options parameter requires a 'descriptionGetOne' field."
  optionsDescriptionDeleteOneRequired: "options parameter requires a 'descriptionDeleteOne' field."
  optionsDescriptionPatchOneRequired: "options parameter requires a 'descriptionPatchOne' field."

  descriptionGetAll: "Return all roles."
  descriptionPost: "Create a new role."
  descriptionGetOne: "Return a specific role."
  descriptionDeleteOne: "Delete a role."
  descriptionPatchOne: "Update a role."
  descriptionRoleId: "The 24 character hexadecimal object id specifying the role."
  exampleObjectId: '01234567890123456789000b'

  couldNotFindPlugin: "Could not find 'hapi-user-store-multi-tenant' plugin."
  couldNotFindMethodsRoles: "Could not find 'methods.roles' in 'hapi-user-store-multi-tenant' plugin."

  notFoundPrefix: "Could not find"
  authorizationRequired: "Authentication required for this endpoint."
  serverAdminScopeRequired: " scope required to access this resource."