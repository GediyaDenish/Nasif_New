import Controller from "@/utils/interfaces/controller.interface"
import { NextFunction, Request, Response, Router } from "express"
import validationMiddleware from "@/middleware/validationMiddleware"
import HttpException from "@/utils/exceptions/httpException"
import User from "@/resources/user/user.interface"
import passportMiddleware from "@/middleware/passportMiddleware"
import UserService from "@/resources/user/user.service"
import Validate from "@/resources/user/user.validation"

class UserController implements Controller {
    public path = '/users'
    public router = Router()
    private userService = new UserService()

    constructor() {
        this.initialiseRoutes()
    }

    private initialiseRoutes(): void {
        this.router.get(
            `${this.path}/`,
            passportMiddleware('jwt'),
            this.getUsers
        );
        this.router.get(
            `${this.path}/me/`,
            passportMiddleware('jwt'),
            this.getMe
        );
        this.router.put(
            `${this.path}/me/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.update),
            this.updateMe
        );
        this.router.delete(
            `${this.path}/delete/me/`,
            passportMiddleware('jwt'),
            this.deleteMe
        )
        this.router.put(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.updateUser),
            this.updateUser
        );
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

    private getUsers = async (req: Request, res: Response, next: NextFunction) : Promise<Response | void> => {
        try {
            
            const { page, size, search, sort } = req.query
            const users = await this.userService.getUsers( page, size, search, sort)

            res.status(200).send(users)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    };

    private getMe = async (req: Request, res: Response, next: NextFunction) : Promise<Response | void> => {
        try {
            const reqUser = req.user as User
            const user = await this.userService.getUserProfile(reqUser.id) as User
            res.status(200).send(user.forProfile())
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private updateMe = async (req: Request, res: Response, next: NextFunction) : Promise<Response | void> => {
        try {
            const { avatar, displayName, code, mobile} = req.body
            const reqUser = req.user as User
            const user = await this.userService.updateProfile(reqUser.id, avatar, displayName, code, mobile)
            res.status(200).send(user)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private deleteMe = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const reqUser = req.user as User
            const user = await this.userService.deleteUser(reqUser) as User
            if(user._id){
                res.status(200).json({status : true, message : 'User deleted successfully.', deleted: true})
            }else{
                res.status(400).json({status : false, message : 'Something went wrong.'})
            }
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    } 

    private updateUser = async (req: Request, res: Response, next: NextFunction) : Promise<Response | void> => {
        try {
            const { isBlocked, isAdmin } = req.body
            const { id } = req.params 
            const user = await this.userService.updateUser(id, isBlocked, isAdmin)
            res.status(200).send({status:true,message:'User updated successfully'})
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getDayCounts = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { days } = req.params
            const counts = await this.userService.getCounts(+days)
            res.status(200).json(counts)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getDaysSummary = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { days } = req.params
            const summary = await this.userService.getDaysSummary(+days)
            res.status(200).json(summary)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }
}


export default UserController;