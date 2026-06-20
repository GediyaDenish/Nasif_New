import Joi from '@hapi/joi';

const policy = Joi.object({
    policy: Joi.string().required(),
});

const terms = Joi.object({
    terms: Joi.string().required(),
});

const contacts = Joi.object({
    contacts: Joi.array().required(),
});

export default { policy, terms, contacts };