import { model, PaginateModel, Schema } from "mongoose"
import mongoosePaginate from 'mongoose-paginate-v2'
import IFaq from "@/resources/faq/faq.interface"

const FaqSchema = new Schema(
    {
        que:{
            type: String,
            required: true,
            trim: true
        },
        ans:{
            type: String,
            required: true,
            trim: true
        }
    },
    { timestamps: true }
)
FaqSchema.plugin(mongoosePaginate)
FaqSchema.methods.toJSON = function() {
    const { __v, _id, createdAt, updatedAt, ...object } = this.toObject()
    object.id = _id
    return object
}

export default model<IFaq, PaginateModel<IFaq>>('Faqs', FaqSchema)