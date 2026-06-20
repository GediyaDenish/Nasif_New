import Joi from "@hapi/joi";

const createGroup = Joi.object({
    admins: Joi.array().items(Joi.string()),
    moderators: Joi.array().items(Joi.string()),
    members: Joi.array().items(Joi.string()),
    contact: Joi.string(),
    groupName: Joi.string(),
    groupImage: Joi.string(),
    groupDescription: Joi.string()
});

const updateGroup = Joi.object({
    groupName: Joi.string(),
    groupImage: Joi.string(),
    admins: Joi.array().items(Joi.string()),
    moderators: Joi.array().items(Joi.string()),
    members: Joi.array().items(Joi.string()),
    groupDescription: Joi.string()
});

const createMessage = Joi.object({
    type: Joi.string().required(),
    file: Joi.string().required(),
    fileType: Joi.string().required(),
    fileName: Joi.string().required(),
});

export default { createGroup, updateGroup, createMessage }