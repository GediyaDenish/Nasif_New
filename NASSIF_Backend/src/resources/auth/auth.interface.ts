import { Document } from 'mongoose';

export default interface Auth extends Document {
    userId: string
    accessToken: string
    type: string
    mobile: string
    code: string
    topic: string
    isNew: boolean
}
