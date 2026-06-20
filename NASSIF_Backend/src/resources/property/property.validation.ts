import Joi from "@hapi/joi";

const create = Joi.object({
    location: Joi.object({
    coordinates: Joi.array()
        .items(Joi.number().required())
        .length(2)
        .required()
    }).required(),
    city: Joi.string().required(),
    neighbourhood: Joi.string(),
    availableFor: Joi.string().required(),
    type: Joi.string().required(),
    price: Joi.number().required(),
    area: Joi.number().required(),
    age: Joi.number().required(),
    northFacing: Joi.number(),
    eastFacing: Joi.number(),
    westFacing: Joi.number(),
    southFacing: Joi.number(),
    vilaType: Joi.string(),
    landType: Joi.string(),
    useFor: Joi.array().items(Joi.string()),
    floorNumber: Joi.number(),
    totalFloors: Joi.number(),
    totalBedrooms: Joi.number(),
    totalBathrooms: Joi.number(),
    totalLivingrooms: Joi.number(),
    availableParking: Joi.number(),
    services: Joi.array().items(Joi.string()),
    extraFeatures: Joi.array().items(Joi.string()),
    coverImage: Joi.string(),
    images: Joi.array().items(Joi.string()),
    advertisersRole: Joi.string().max(20),
    planNumber: Joi.string().max(30),
    plotNumber: Joi.string().max(30),
    falLicenseNumber: Joi.string().max(30),
    licenseNumber: Joi.string().max(30),
    ownerName: Joi.string().max(30),
    ownerNumber: Joi.string().min(9).max(10),
    description: Joi.string().max(1500),
    status: Joi.string()
})

const update = Joi.object({
    location: Joi.object({
    coordinates: Joi.array()
        .items(Joi.number().required())
        .length(2)
        .required()
    }).required(),
    city: Joi.string().required(),
    neighbourhood: Joi.string(),
    availableFor: Joi.string().required(),
    type: Joi.string().required(),
    price: Joi.number().required(),
    area: Joi.number().required(),
    age: Joi.number().required(),
    northFacing: Joi.number(),
    eastFacing: Joi.number(),
    westFacing: Joi.number(),
    southFacing: Joi.number(),
    vilaType: Joi.string(),
    landType: Joi.string(),
    useFor: Joi.array().items(Joi.string()),
    floorNumber: Joi.number(),
    totalFloors: Joi.number(),
    totalBedrooms: Joi.number(),
    totalBathrooms: Joi.number(),
    totalLivingrooms: Joi.number(),
    availableParking: Joi.number(),
    services: Joi.array().items(Joi.string()),
    extraFeatures: Joi.array().items(Joi.string()),
    coverImage: Joi.string(),
    images: Joi.array().items(Joi.string()),
    advertisersRole: Joi.string().max(20),
    planNumber: Joi.string().max(30),
    plotNumber: Joi.string().max(30),
    falLicenseNumber: Joi.string().max(30),
    licenseNumber: Joi.string().max(30),
    ownerName: Joi.string().max(30),
    ownerNumber: Joi.string().min(9).max(10),
    description: Joi.string().max(1500),
    status: Joi.string()
})

const share = Joi.object({
    users: Joi.array().items(Joi.string()).required(),
    contact: Joi.string()
});

export default { create, update, share}