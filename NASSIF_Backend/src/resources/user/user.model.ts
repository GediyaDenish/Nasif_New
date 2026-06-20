import mongoose, { Schema, model, PaginateModel } from 'mongoose'
import mongoosePaginate from 'mongoose-paginate-v2'
import bcrypt from 'bcrypt'
import User from '@/resources/user/user.interface'

const UserSchema = new Schema(
    {
        avatar:{
            type: String,
            trim: true
        },
        displayName: {
            type: String,
            trim: true
        },
        code: {
            type: String,
            required: true,
            trim: true
        },
        mobile: {
            type: String,            
            required: true,
            trim: true
        },
        password: {
            type: String,
            required: true,
            trim: true
        },
        role: {
            type: [String],
            required: true,
            trim: true,
            default: 'user'
        },
        isBlocked: {
            type: Boolean,
            required: true,
            default: false
        },
        isDeleted: {
            type: Boolean,
            required: true,
            default: false
        },
        passwordExpiredIn: {
            type: Date,
            trim: true
        },
        blockChatUser:[
            {
                type: mongoose.SchemaTypes.ObjectId
            }
        ],
        token:{
            type: String,
            trim: true
        }
    },
    { timestamps: true }
)

UserSchema.plugin(mongoosePaginate)

UserSchema.pre<User>('save', async function (next) {
    if(!this.isModified('password')) {
        return next();
    }
    const hash = await bcrypt.hash(this.password, 10)
    this.password = hash
    this.passwordExpiredIn = new Date(Date.now() + 10 * 60 * 1000).toISOString();

    next()
});

UserSchema.methods.isValidPassword = async function (
    password: string
): Promise<Error | boolean> {
    return await bcrypt.compare(password, this.password)
}

UserSchema.methods.forProfile = function(): Promise<User> {
    const { __v, _id, password, role, passwordExpiredIn, createdAt, updatedAt,blockChatUser,token, ...object } = this.toObject()
    object.id = _id
    object.role = role?.join(',')
    return object;
}

UserSchema.methods.forList = function(): Promise<User>  {
    const { __v, _id, password, role, passwordExpiredIn, createdAt, updatedAt,blockChatUser,token,  ...object } = this.toObject()
    object.id = _id
    object.role = role?.join(',')
    return object
}

UserSchema.methods.toJSON = function() {
    const { __v, _id, role, password, passwordExpiredIn, createdAt, updatedAt,blockChatUser,token, ...object } = this.toObject();
    object.id = _id
    object.role = role?.join(',')
    return object;
  }

export default model<User, PaginateModel<User>>('User', UserSchema)