import Controller from "@/utils/interfaces/controller.interface"
import { NextFunction, Request, Response, Router } from "express"
import HttpException from "@/utils/exceptions/httpException"
import passportMiddleware from "@/middleware/passportMiddleware"
import path from "path"
import fs from 'fs'
import validationMiddleware from "@/middleware/validationMiddleware"
import CommonService from "@/resources/common/common.service"
import Validate from '@/resources/common/common.validation'
import IUser from "@/resources/user/user.interface"
import IContact from "./common.interface"

class CommonController implements Controller {
    public path = '/commons'
    public router = Router()
    private service = new CommonService()

    constructor() {
        this.initialiseRoutes()
    }

    private initialiseRoutes(): void {
        this.router.get(
            `${this.path}/policy/`,
            this.getPolicy
        )
        this.router.put(
            `${this.path}/policy/`,
            passportMiddleware('jwt','admin'),
            validationMiddleware(Validate.policy),
            this.updatePolicy
        )
        this.router.get(
            `${this.path}/terms/`,
            this.getTerms
        )
        this.router.put(
            `${this.path}/terms/`,
            passportMiddleware('jwt','admin'),
            validationMiddleware(Validate.terms),
            this.updateTerms
        )
        this.router.post(
            `${this.path}/contacts/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.contacts),
            this.checkContacts
        )

        this.router.get(
            `${this.path}/neighborhoods/`,
            this.getNeighborhoods
        )
    }

    private getPolicy = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const policy = fs.readFileSync(path.join(__dirname,'../../../public/policy.html'))
            res.status(200).json({id:"policy",value:"policy",display:policy.toString()})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private updatePolicy = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        const { policy } = req.body
        try {
            fs.writeFileSync(path.join(__dirname,'../../../public/policy.html'),policy);
            res.status(200).json({status:true, message:"Privacy policy updated successfully"})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getTerms = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const terms = fs.readFileSync(path.join(__dirname,'../../../public/terms.html'))
            res.status(200).json({id:"terms",value:"terms",display:terms.toString()})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private updateTerms = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        const { terms } = req.body
        try {
            fs.writeFileSync(path.join(__dirname,'../../../public/terms.html'),terms);
            res.status(200).json({status:true, message:"Terms of use updated successfully"})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private checkContacts = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {        
        try {
            const contacts: IContact[] = req.body.contacts;
            const user = req.user as IUser
            const validatedContacts = await this.service.validateContacts(contacts, user)
            res.status(200).json(validatedContacts)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getNeighborhoods = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const terms = fs.readFileSync(path.join(__dirname,'../../../public/neighborhoods.json'))
            const neighborhoods = JSON.parse(terms.toString()); // parse the JSON string to object
            res.status(200).json(neighborhoods)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }
}

export default CommonController