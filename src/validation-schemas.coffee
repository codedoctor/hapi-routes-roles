Joi = require "joi"

validateId = Joi.string().length(24)
validateMe = Joi.string().valid(['me'])
validateUsername = Joi.string().min(2).max(100)
validateUsernameOrIdOrMe = Joi.alternatives([validateId,validateMe,validateUsername])


module.exports =
  validateId: validateId
  validateMe: validateMe
  validateUsername: validateUsername
  validateUsernameOrIdOrMe : validateUsernameOrIdOrMe

  ###
  payloadUsersPost : Joi.object().keys(
      username: Joi.string().min(minLoginLength).max(maxLoginLength).required().example('johnsmith')
      name: Joi.string().min(2).max(40).required().example('John Smith')
      password: validatePassword.required()
      email: Joi.string().email().required().example('john@smith.com')
    ).with('username', 'password','email','name').options({ allowUnkown: true, stripUnknown: true })

  payloadUsersResetPasswordPost : Joi.object().keys(
    login: Joi.string().min(minLoginLength).max(maxLoginLength).required().example('johnsmith').description('The login field can either be an email address or a username.')
    ).options({ allowUnkown: true, stripUnknown: true })

  payloadUsersResetPasswordTokensPost : Joi.object().keys(
    password: validatePassword.required().description('The new password for the user referenced by the token.')
    token: Joi.string().min(20).max(100).required().example('2JkfnuslAY53dd011b5ff6cb3970260b42pYhkPGfPHy').description('The token obtained through a POST request at /users/reset-password.')
    ).options({ allowUnkown: true, stripUnknown: true })

  payloadUsersPasswordPut : Joi.object().keys(
    password: validatePassword.required().description('The new password for the user.')
    ).options({ allowUnkown: true, stripUnknown: true })

  paramsUsersPasswordPut: Joi.object().keys(
      usernameOrIdOrMe: validateUsernameOrIdOrMe.required() 
    )

  paramsUsersDelete: Joi.object().keys(
      usernameOrIdOrMe: validateUsernameOrIdOrMe.required() 
    )

  payloadUsersPatch : Joi.object().keys(
    password: validatePassword.description('The new password for the user.')
    ).options({ allowUnkown: true, stripUnknown: true })

  paramsUsersPatch: Joi.object().keys(
      usernameOrIdOrMe: validateUsernameOrIdOrMe.required() 
    )
  ###

  paramsRolesDelete: Joi.object().keys(
      roleId: validateId.required() 
    )

  paramsRolesGet: Joi.object().keys()

  payloadRolesPost: Joi.object().keys(
      name: Joi.string().min(1).max(100).required().example('role1').description('The name of this role')
      description: Joi.string().length(100).description('The end user description for this role')
      isInternal: Joi.boolean().default(false).description('True when used internally, otherwise visible to end users.')

    ).options({ allowUnkown: true, stripUnknown: false })

