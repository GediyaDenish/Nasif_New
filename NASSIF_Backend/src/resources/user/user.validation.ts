import Joi from '@hapi/joi';

const update = Joi.object({
    avatar: Joi.string(),
    displayName: Joi.string().max(30).required(),
    code: Joi.string().min(2).max(3),
    mobile: Joi.string().min(9).max(10)
});

const updateUser = Joi.object({
    isBlocked:Joi.boolean(),
    isAdmin:Joi.boolean()
})

export default { update, updateUser};