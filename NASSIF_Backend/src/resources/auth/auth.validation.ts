import Joi from '@hapi/joi';

const checkUser = Joi.object({
    code: Joi.string().min(2).max(3).required(),
    mobile: Joi.string().min(9).max(10).required()
});

const verifyUser = Joi.object({
    code: Joi.string().min(2).max(3).required(),
    mobile: Joi.string().min(9).max(10).required(),
    otp: Joi.string().min(4).required(),
});

export default { checkUser, verifyUser };