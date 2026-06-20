import mongoose, { model, PaginateModel, Schema } from "mongoose"
import mongoosePaginate from 'mongoose-paginate-v2'
import IChatMessage from "./message.interface"

const ChatMessageSchema = new Schema(
    {
        chat:{
            type: mongoose.SchemaTypes.ObjectId,
            required: true,
        },
        sender:{
            type: mongoose.SchemaTypes.ObjectId,
            required: true,
        },
        property:{
            type: mongoose.SchemaTypes.ObjectId,
        },
        type:{
            type: String,
            enum: ['Title', 'Text', 'Image', 'File','Video', 'Property'],
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

ChatMessageSchema.plugin(mongoosePaginate)

ChatMessageSchema.methods.toJSON = function() {
    const { __v, _id, updatedAt, isDeleted, ...object } = this.toObject()
    object.id = _id
    return object
}

ChatMessageSchema.methods.toList = function() {
    const { __v, _id, updatedAt, isDeleted, ...object } = this.toObject()
    object.id = _id
    return object
}

export default mongoose.models.Car as PaginateModel<IChatMessage> || model<IChatMessage, PaginateModel<IChatMessage>>('ChatMessages', ChatMessageSchema)