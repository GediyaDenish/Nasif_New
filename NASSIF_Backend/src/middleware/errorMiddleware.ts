import HttpException from "@/utils/exceptions/httpException";
import { Request, Response, NextFunction } from "express";

function errorMiddleware(
    err: HttpException,
    req: Request,
    res: Response,
    next: NextFunction
): void {
    const code = err.status || 500
    const status = false
    const message = err.message || 'Something went wrong'
    res.status(code).send({
        status,
        message
    });
}

export default errorMiddleware;
