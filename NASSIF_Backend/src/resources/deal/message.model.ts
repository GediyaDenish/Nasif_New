import mongoose, { model, PaginateModel, Schema } from "mongoose"
import mongoosePaginate from 'mongoose-paginate-v2'
import IDealMessage from "@/resources/deal/message.interface"

const DealMessageSchema = new Schema(
    {
        deal:{
            type: mongoose.SchemaTypes.ObjectId,
            required: true,
        },
        sender:{
            type: mongoose.SchemaTypes.ObjectId,
            required: true,
        },
        type:{
            type: String,
            enum: ['Title', 'Text', 'Image', 'File'],
            required: true
        },
        text:{
            type: String,
            trim: true
        },
        file:{
            type: String,
            trim: true
        },
        fileType:{
            type: String,
            enum: ['image', 'video','pdf', 'word'],
            trim: true
        },
        fileName:{
            type: String,
            trim: true
        },
        isDeleted:{
            type: Boolean,
            require: true,
            default: false,
        }
    },
    { timestamps: true }
)

DealMessageSchema.plugin(mongoosePaginate)

DealMessageSchema.methods.toJSON = function() {
    const { __v, _id, updatedAt, isDeleted, ...object } = this.toObject()
    object.id = _id
    return object
}

DealMessageSchema.methods.toList = function() {
    const { __v, _id, updatedAt, isDeleted, ...object } = this.toObject()
    object.id = _id
    return object
}

export default mongoose.models.Car as PaginateModel<IDealMessage> || model<IDealMessage, PaginateModel<IDealMessage>>('DealMessages', DealMessageSchema)