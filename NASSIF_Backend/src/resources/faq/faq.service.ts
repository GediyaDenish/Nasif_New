import FaqModel from "@/resources/faq/faq.model"
import { PaginateOptions, PaginateResult } from "mongoose"
import IFaq from "@/resources/faq/faq.interface"

class FaqService {
    private faqModel = FaqModel
    private customLabels = { totalDocs: "totalElements", docs: "content", limit: "size", page: "page" }        

    public async getFaqs(
        page:any = 0,
        size:any = 20,
        search:any = '',
        sort: any
    ): Promise<PaginateResult<IFaq> | Error> {
        try {
            const options:PaginateOptions = {
                page: +page,
                limit: size,
                sort: sort,
                customLabels: this.customLabels
            }
            return await this.faqModel.paginate({$or: [{que: { $regex: search, $options: "i" }},{ans: { $regex: search, $options: "i" }}]},options)
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async createFaq(que:string,ans:string): Promise<IFaq | Error> {
        try {
            let faq = await this.faqModel.create({que:que,ans:ans}) as IFaq
            return faq ? faq : new Error("Failed to create faq")
        }catch (error: any) {
            throw new Error(error.message)
        }        
    }

    public async updateFaq(id:string,que:string,ans:string): Promise<IFaq | Error> {
        try {
            let faq = await this.faqModel.findById(id) as IFaq
            if(!faq) new Error("Faq not found")
            faq.que = que
            faq.ans = ans
            return await this.faqModel.findByIdAndUpdate(id,faq,{new: true}) as IFaq
        }catch (error: any) {
            throw new Error(error.message)
        } 
    }

    public async deleteFaq(id:string): Promise<boolean | Error> {
        const deleted = await this.faqModel.deleteOne({ _id: { $eq: id } })
        return deleted != null ? true : new Error('Failed to delete faq')
    }
}
export default FaqService