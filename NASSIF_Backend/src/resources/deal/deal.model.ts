import mongoose, { model, PaginateModel, Schema } from "mongoose"
import mongoosePaginate from 'mongoose-paginate-v2'
import AllSequence from "@/utils/sequence"
import IDeal from "@/resources/deal/deal.interface";

const DealSchema = new Schema(
    {
        dealNo:{
            type: Number,
            default: 0
        },
        name:{
            type: String,
            trim: true
        },
        property:{
            type: mongoose.SchemaTypes.ObjectId,
            required: true,
        },
        user:{
            type: mongoose.SchemaTypes.ObjectId,
            required: true,
        },
        userExit:{
            type: Boolean,
            default: false
        },
        buyer:{
            type: mongoose.SchemaTypes.ObjectId,
            required: true,
        },
        buyerExit:{
            type: Boolean,
            default: false
        },
        status:{
            type: String,
            enum: ['Inquiries','Negotiations', 'Completion'],
            required: true,
            default: 'Inquiries'
        },
        subStatus:{
            type: Number,
            require: true,
            default: 0
        },
        lastMessage:{
            type: mongoose.SchemaTypes.ObjectId
        },
        userUnreadMsg:{
            type: Number,
            default: 0
        },
        buyerUnreadMsg:{
            type: Number,
            default: 0
        },
        isDeleted:{
            type: Boolean,
            default: false
        },
        archivedBy:[
            {
                type: mongoose.SchemaTypes.ObjectId
            }
        ]
    },
    { timestamps: true }
)

DealSchema.plugin(mongoosePaginate)

DealSchema.pre("save", async function (next) {
  if (this.isNew) {
    const sequence = await AllSequence.findByIdAndUpdate(
      { _id: "deal" },
      { $inc: { seq: 1 } },
      { new: true, upsert: true }
    );
    this.dealNo = sequence.seq ?? 0;
  }
  next();
});

DealSchema.methods.toJSON = function(userId:string) {
    const { __v, _id, createdAt, updatedAt, isDeleted, isArchived,  ...object } = this.toObject()
    object.id = _id
    object.isExit = userId == object.user._id ? object.userExit :  object.buyerExit
    object.isArchived = object.archivedBy.includes(userId) 
    object.unReadMsg = userId == object.user._id ? object.userUnreadMsg :  object.buyerUnreadMsg
    object.userExit = undefined,
    object.buyerExit = undefined,
    object.userUnreadMsg = undefined,
    object.buyerUnreadMsg = undefined,
    object.archivedBy = undefined
    return object
}

DealSchema.methods.toList = function(userId:string) {
    const { __v, _id, createdAt, updatedAt, isDeleted, isArchived,  ...object } = this.toObject()
    object.id = _id
    object.isExit = userId == object.user._id ? object.userExit : object.buyerExit
    object.isArchived = object.archivedBy.includes(userId)
    object.unReadMsg = userId == object.user._id ? object.userUnreadMsg :  object.buyerUnreadMsg
    object.userExit = undefined,
    object.buyerExit = undefined,
    object.userUnreadMsg = undefined,
    object.buyerUnreadMsg = undefined,
    object.archivedBy = undefined
    return object
}

export default mongoose.models.Car as PaginateModel<IDeal> || model<IDeal, PaginateModel<IDeal>>('Deals', DealSchema)