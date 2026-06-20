import Joi from "@hapi/joi";

const create = Joi.object({
    propertyId: Joi.string().required(),
    buyerId: Joi.string().required(),
    contact: Joi.string()
});

const update = Joi.object({
    name: Joi.string()
});


const createMessage = Joi.object({
    type: Joi.string().required(),
    file: Joi.string().required(),
    fileType: Joi.string().required(),
    fileName: Joi.string().required(),
});


export default { create, update, createMessage }