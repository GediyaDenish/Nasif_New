import HttpException from '@/utils/exceptions/httpException';
import { NextFunction, Request, RequestHandler, Response } from 'express'
import passport from '@/utils/passport';
import User from '@/resources/user/user.interface';

function passportMiddleware(type:string, role?:string): RequestHandler {
    return async (
        req: Request,
        res: Response,
        next: NextFunction
    ): Promise<void> => {
        const token = req.headers.authorization?.split(' ')[1];
        if(!role){ role = 'user' }
        if(type == 'local'){
            
            passport.authenticate("local", { session: false }, (err: any, user: User | undefined, info: any) => {
                if (err || !user || user?.token != token) {
                    next(new HttpException(401,"Invalid username or password"))
                }else{
                    if (role && !user.role.includes(role)){
                        next(new HttpException(403,"Access denied"))
                    }else if (user.isBlocked){
                        next(new HttpException(400,"Account is blocked"))
                    }
                    req.user = user
                    next();
                }
            })(req, res, next)
        }else{
            passport.authenticate('jwt', { session: false }, (err: any, user: User | undefined, info: any) => {
                if (err || !user || user?.token != token) {
                    next(new HttpException(401,"Unauthorized"))
                }else {
                    if (role && !user.role.includes(role)){
                        next(new HttpException(403,"Access denied"))
                    }else if (user.isBlocked){
                        next(new HttpException(400,"Account is blocked"))
                    }
                    req.user = user
                    next()
                }                
            })(req, res, next)
        }
    };
}

export default passportMiddleware