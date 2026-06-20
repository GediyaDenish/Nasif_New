import passportMiddleware from "@/middleware/passportMiddleware"
import validationMiddleware from "@/middleware/validationMiddleware"
import HttpException from "@/utils/exceptions/httpException"
import Controller from "@/utils/interfaces/controller.interface"
import Validate from '@/resources/auth/auth.validation'
import { NextFunction, Request, Response, Router  } from "express"
import AuthService from "@/resources/auth/auth.service"
import User from "@/resources/user/user.interface"
import Auth from "./auth.interface"

class AuthController implements Controller {
    public path = '/auth'
    public router = Router()
    private service = new AuthService()

    constructor() {
        this.initialiseRoutes()
    }

    private initialiseRoutes(): void {
        this.router.post(
            `${this.path}/signup`,
            validationMiddleware(Validate.checkUser),
            this.signUpUser
        )
        this.router.post(
            `${this.path}/signin`,
            validationMiddleware(Validate.checkUser),
            this.signInUser
        )
        this.router.post(
            `${this.path}/verify`,
            validationMiddleware(Validate.verifyUser),
            this.verifyUser
        )
    }

    private signUpUser = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { code, mobile } = req.body
            await this.service.signUpUser(code, mobile) as User
            res.status(200).json({status : true, message : 'OTP sent to your mobile'})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private signInUser = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { code, mobile } = req.body
            await this.service.signInUser(code, mobile) as User
            res.status(200).json({status : true, message : 'OTP sent to your mobile'})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private verifyUser = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { code, mobile, otp } = req.body
            const auth = await this.service.verifyUser(code,mobile,otp) as Auth
            if(auth){
                res.status(200).json(auth)
            }else{
                res.status(400).json({status : false, message : 'Invalid mobile and OTP.'})
            }
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }
}

export default AuthController