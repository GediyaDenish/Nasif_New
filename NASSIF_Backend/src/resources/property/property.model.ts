import mongoose, { model, PaginateModel, Schema } from "mongoose"
import mongoosePaginate from 'mongoose-paginate-v2'
import AllSequence from "@/utils/sequence"
import IProperty from "@/resources/property/property.interface";

const PropertySchema = new Schema(
    {
        listingNo:{
            type: Number,
            default: 0
        },
        user:{
            type: mongoose.SchemaTypes.ObjectId,
            required: true,
        },
        location: {
            type: {
                type: String,
                enum: ['Point'],
                required: true,
                default: 'Point'
            },
            coordinates: {
                type: [Number], // [longitude, latitude]
                required: true
            }
        },
        city: {
            type: String,
            required: true,
            trim: true
        },
        neighbourhood:{
            type: String,
            trim: true
        },
        availableFor:{
            type: String,
            enum: ['Rent','Sale'],
            required: true,
        },
        status:{
            type: String,
            enum: ['Sold','Reserved', 'Available'],
            required: true,
            default: 'Available'
        },
        type: {
            type: String,
            enum: ['Floor','Apartment','Villa','Land','Farm','Chalet','Building Complex','Other'],
            required: true,
        },
        price: {
            type: Number,
            required: true,
            default: 0
        },
        area: {
            type: Number,
            required: true,
            default: 0
        },
        age:{
            type: Number,
            required: true,
            default: 0
        },
        northFacing:{
            type: Number,
            required: true,
            default: 0
        },
        eastFacing:{
            type: Number,
            required: true,
            default: 0
        },
        westFacing:{
            type: Number,
            required: true,
            default: 0
        },
        southFacing:{
            type: Number,
            required: true,
            default: 0
        },
        streets:{
            type: Number,
            required: true,
            default: 0
        },
        vilaType:{
            type: String,
            enum: ['Toenhouse','Duplex','Villa'],
        },
        landType:{
            type: String,
            enum: ['Undeveloped Land','Farming','Commercial','Ch'],
        },
        useFor:{
            type: [String],
            enum: ['Residential','Commercial','Farming','Raw Land'],
        },
        floorNumber:{
            type: Number,
            required: true,
            default: 0
        },
        totalFloors:{
            type: Number,
            required: true,
            default: 0
        },
        totalBedrooms:{
            type: Number,
            required: true,
            default: 0
        },
        totalBathrooms:{
            type: Number,
            required: true,
            default: 0
        },
        totalLivingrooms:{
            type: Number,
            required: true,
            default: 0
        },
        availableParking:{
            type: Number,
            required: true,
            default: 0
        },
        services:{
            type: [String],
            enum: ['Running Water','Electricity','Sewage System','Fiber-optic Internet','Phone','Flood Disposal System'],
        },
        extraFeatures:{
            type: [String],
            enum: ['Kitchen','AC','Furnished','Underground Parking','Backyard','Top Floor','Underground Parking','Laundry Room','Driver Room','Housemaid Room','Private Entrance', 'Compound Complex', 'Balcony'],
        },
        coverImage:{
            type: String,
            trim: true
        },
        images:{
            type: [String],
            trim: true
        },
        advertisersRole:{
            type: String,
            trim: true
        },
        planNumber:{
            type: String,
            trim: true
        },
        plotNumber:{
            type: String,
            trim: true
        },
        falLicenseNumber:{
            type: String,
            trim: true
        },
        licenseNumber:{
            type: String,
            trim: true
        },
        ownerNumber:{
            type: String,
            trim: true
        },
        ownerName:{
            type: String,
            trim: true
        },
        description:{
            type: String,
            trim: true
        },
        sharedWith:[
            {
                type: mongoose.SchemaTypes.ObjectId
            }
        ],
        isDeleted:{
            type: Boolean,
            default: false
        },
        sharedHideFor:[
            {
                type: mongoose.SchemaTypes.ObjectId
            }
        ],
    },
    { timestamps: true }
)


PropertySchema.plugin(mongoosePaginate)
PropertySchema.index({ location: '2dsphere' });

PropertySchema.pre("save", async function (next) {
  if (this.isNew) {
    const sequence = await AllSequence.findByIdAndUpdate(
      { _id: "property" },
      { $inc: { seq: 1 } },
      { new: true, upsert: true }
    );
    this.listingNo = sequence.seq ?? 0;
  }
  next();
});

PropertySchema.methods.toJSON = function(userId:string) {
    const { __v, _id, createdAt, updatedAt,streets,sharedWith, ...object } = this.toObject()
    object.id = _id
    object.userDetail = object.user
    object.user = object.userDetail._id
    object.isHidden = object.sharedHideFor?.some((i:string) => i == userId)
    object.sharedHideFor = undefined
    return object
}

PropertySchema.methods.toList = function(userId:string) {
    const { __v, _id, createdAt, updatedAt, age, vilaType, landType, useFor, floorNumber, totalFloors,  totalLivingrooms, availableParking, services, extraFeatures, advertisersRole, planNumber, plotNumber, falLicenseNumber, licenseNumber, ownerNumber, description, sharedWith,sharedHideFor, isHidden, ...object } = this.toObject()
    object.id = _id
    return object
}

export default mongoose.models.Car as PaginateModel<IProperty> || model<IProperty, PaginateModel<IProperty>>('Properties', PropertySchema)