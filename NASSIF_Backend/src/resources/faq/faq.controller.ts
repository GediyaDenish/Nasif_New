import Controller from "@/utils/interfaces/controller.interface"
import { NextFunction, Request, Response, Router } from "express"
import FaqService from "@/resources/faq/faq.service"
import passportMiddleware from "@/middleware/passportMiddleware"
import validationMiddleware from "@/middleware/validationMiddleware"
import Validate from '@/resources/faq/faq.validation'
import HttpException from "@/utils/exceptions/httpException"

class FaqsController implements Controller {
    public path = '/faqs'
    public router = Router()
    private faqService = new FaqService()

    constructor() {
        this.initialiseRoutes()
    }

    private initialiseRoutes(): void {
        this.router.get(
            `${this.path}/`,
            this.getFaqs
        )
        this.router.post(
            `${this.path}/`,
            passportMiddleware('jwt','admin'),
            validationMiddleware(Validate.faqs),
            this.createFaq
        )
        this.router.put(
            `${this.path}/:id`,
            passportMiddleware('jwt','admin'),
            validationMiddleware(Validate.faqs),
            this.updateFaq
        )
        this.router.delete(
            `${this.path}/:id/`,
            passportMiddleware('jwt','admin'),
            this.deleteFaq
        )
    }


    private getFaqs = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { page, size, search, sort } = req.query
            const faqs = await this.faqService.getFaqs( page, size, search, sort)
            res.status(200).json(faqs)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private createFaq = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        const { que, ans } = req.body
        try {
            const faq = await this.faqService.createFaq(que, ans)
            res.status(200).json({status:true, message:"Faq created successfully"})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private updateFaq = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        const { id } = req.params
        const { que, ans } = req.body
        try {
            const faq = await this.faqService.updateFaq(id, que, ans)
            res.status(200).json({status:true, message:"Faq updated successfully"})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private deleteFaq = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        const { id } = req.params
        try {
            await this.faqService.deleteFaq(id)
            res.status(200).json({status:true, message:"Faq deleted successfully"})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

}
export default FaqsController