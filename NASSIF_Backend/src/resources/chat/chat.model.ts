import mongoose, { model, PaginateModel, Schema } from "mongoose"
import mongoosePaginate from 'mongoose-paginate-v2'
import IChat from "@/resources/chat/chat.interface"
import IUser from "../user/user.interface"

const ChatSchema = new Schema(
    {
        lastMessage:{
            type: mongoose.SchemaTypes.ObjectId
        },
        isGroup:{
            type: Boolean,
            default: false
        },
        groupName:{
            type: String,
            trim: true
        },
        groupImage:{
            type: String,
            trim: true,
        },
        groupDescription:{
            type: String,
            trim: true,
        },
        isDeleted:{
            type: Boolean,
            default: false
        },
        archived:[
            {
                type: mongoose.SchemaTypes.ObjectId,
            }
        ],
        admin:[
            {
                type: mongoose.SchemaTypes.ObjectId,
                ref: 'User'
            }
        ],
        moderator:[
            {
                type: mongoose.SchemaTypes.ObjectId,
                ref: 'User'
            }
        ],
        member:[
            {
                type: mongoose.SchemaTypes.ObjectId,
                ref: 'User'
            }
        ],
        unreadMsg:[
            new Schema({
                user: {
                    type: Schema.Types.ObjectId,
                    required: true
                },
                count: {
                    type: Number,
                    default: 0
                }
            })
        ],
    },
    { timestamps: true }
)

ChatSchema.plugin(mongoosePaginate)
ChatSchema.methods.toJSON = function(user:IUser) {
    const { __v, _id, createdAt, updatedAt, isDeleted, ...object } = this.toObject()
    object.id = _id
    object.isArchived = object.archived?.some((id:string) => id == user.id)
    object.unRead =  object.unreadMsg?.find((obj: any) => obj.user == user.id)?.count || 0;
    object.isAdmin = object.admin?.find((i:any) => i._id == user.id) != null;
    object.isModerator = object.moderator?.find((i:any) => i._id == user.id) != null;
    object.isMember = object.member?.find((i:any) => i._id == user.id) != null;
    object.oposition = object.isGroup ? undefined : object.member?.find((obj: any) => obj._id != user.id)
    object.totalPeoples = (object.member?.length ?? 0) + (object.admin?.length ?? 0) + (object.moderator?.length ?? 0)
    object.archived = undefined
    object.unreadMsg = undefined
    object.isBlock = object.oposition == undefined ? false : user.blockChatUser?.some((id:any) => id.equals(object.oposition._id))
    return object
}

ChatSchema.methods.toList = function(user:IUser) {
    const { __v, _id, createdAt, updatedAt, isDeleted, ...object } = this.toObject()
    object.id = _id
    object.isArchived = object.archived?.some((id:string) => id == user.id)
    object.unRead = object.unreadMsg?.find((obj: any) => obj.user == user.id)?.count || 0
    object.isAdmin = object.admin?.some((id:string) => id == user.id)
    object.isModerator = object.moderator?.some((id:string) => id == user.id)
    object.isMember = object.member?.some((id:string) => id == user.id)
    object.archived = undefined
    object.unreadMsg = undefined
    object.admin = undefined
    object.moderator = undefined
    object.oposition = object.isGroup ? undefined : object.member?.find((obj: any) => obj._id != user.id)
    object.isBlock = object.oposition == undefined ? false : user.blockChatUser?.some((id:any) => id.equals(object.oposition._id))
    object.member = undefined
    return object
}

export default mongoose.models.Car as PaginateModel<IChat> || model<IChat, PaginateModel<IChat>>('Chats', ChatSchema)