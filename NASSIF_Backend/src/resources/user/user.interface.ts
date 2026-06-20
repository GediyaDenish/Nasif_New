import { Document } from 'mongoose'

export default interface IUser extends Document {
    avatar: string
    displayName: string
    code: string
    mobile: string
    password: string
    role: [string]
    isBlocked: boolean
    isDeleted: boolean
    isDealer: boolean,
    passwordExpiredIn: string,
    blockChatUser: string[],
    token:string,
    isValidPassword(password: string): Promise<Error | boolean>
    forProfile(): Promise<IUser>
}
