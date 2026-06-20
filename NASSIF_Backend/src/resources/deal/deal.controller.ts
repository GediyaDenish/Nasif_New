import passportMiddleware from "@/middleware/passportMiddleware"
import validationMiddleware from "@/middleware/validationMiddleware"
import HttpException from "@/utils/exceptions/httpException"
import Controller from "@/utils/interfaces/controller.interface"
import { NextFunction, Request, Response, Router } from "express"
import IUser from "@/resources/user/user.interface"
import DealService from "@/resources/deal/deal.service"
import IDeal from "@/resources/deal/deal.interface"
import Validate from "@/resources/deal/deal.validation"
import IDealMessage from "./message.interface"

class DealController implements Controller {
    public path = '/deals'
    public router = Router()
    private service = new DealService()

    constructor() {
        this.initialiseRoutes()
    }

    private initialiseRoutes(): void {
        this.router.get(
            `${this.path}/`,
            passportMiddleware('jwt'),
            this.getDeals
        ),

        this.router.get(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            this.getDeal
        )

        this.router.get(
            `${this.path}/:id/messages/`,
            passportMiddleware('jwt'),
            this.getDealMessages
        )

        this.router.post(
            `${this.path}/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.create),
            this.createDeal
        )

        this.router.post(
            `${this.path}/:id/message/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.createMessage),
            this.createDealMessage
        )

        this.router.put(
            `${this.path}/:id/status/:status/`,
            passportMiddleware('jwt'),
            this.changeDealStatus
        )

        this.router.put(
            `${this.path}/:id/archived/`,
            passportMiddleware('jwt'),
            this.archivedDeal
        )

        this.router.put(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.update),
            this.updateDeal
        )

        this.router.delete(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            this.deleteDeal
        )

        this.router.delete(
            `${this.path}/:id/exit/`,
            passportMiddleware('jwt'),
            this.exitDeal
        )

        this.router.get(
            `${this.path}/:days/count/`,
            passportMiddleware('jwt'),
            this.getDayCounts
        )

        this.router.get(
            `${this.path}/:days/summary/`,
            passportMiddleware('jwt'),
            this.getDaysSummary
        )
    }

    private getDeals = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { page, size, search, sort, status, archived} = req.query
            const deals = await this.service.getDeals( page, size, search, sort, user, status, archived)
            res.status(200).json(deals)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getDeal = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const deal = await this.service.getDeal(id,user)
            res.status(200).json(deal)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getDealMessages = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const {page, size, search, sort} = req.query
            const deal = await this.service.getDealMessages(page, size, search, sort, user, id)
            res.status(200).json(deal)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private createDealMessage = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id } = req.params
            // const { deal, sender, type, file, fileType, fileName } = req.body
            const message = {
                deal: id,
                sender: user.id,
                type: req.body.type,
                file: req.body.file,
                fileType: req.body.fileType,
                fileName: req.body.fileName
            }
            const dealMessage = await this.service.createDealMessage(message) as IDealMessage
            res.status(200).json(dealMessage)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private createDeal = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { propertyId, buyerId, contact } = req.body
            const deal = await this.service.createDeal(user, propertyId, buyerId, contact) as IDeal
            res.status(200).json(deal)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private updateDeal = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id } = req.params
            const { name } = req.body
            const deal = await this.service.updateDeal(user,id, name) as IDeal
            res.status(200).json(deal)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private changeDealStatus = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id, status } = req.params
            const user = req.user as IUser
            const deal = await this.service.changeDealStatus(id,status,user)
            res.status(200).json(deal)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private archivedDeal = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const deal = await this.service.archivedDeal(id,user)
            res.status(200).json(deal)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private deleteDeal = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const deal = await this.service.deleteDeal(id,user) as IDeal
            res.status(200).json(deal)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private exitDeal = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const deal = await this.service.exitDeal(id,user) as IDeal
            res.status(200).json(deal)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getDayCounts = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { days } = req.params
            const counts = await this.service.getCounts(+days)
            res.status(200).json(counts)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getDaysSummary = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { days } = req.params
            const summary = await this.service.getDaysSummary(+days)
            res.status(200).json(summary)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }
}
export default DealController