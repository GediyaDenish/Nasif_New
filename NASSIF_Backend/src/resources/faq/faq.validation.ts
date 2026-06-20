import Joi from '@hapi/joi';

const faqs = Joi.object({
    que: Joi.string().required(),
    ans: Joi.string().required(),
});

export default { faqs };