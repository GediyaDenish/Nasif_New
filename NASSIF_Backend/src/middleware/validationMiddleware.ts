import express from 'express'
import Joi from '@hapi/joi'

function validationMiddleware(schema: Joi.Schema): express.RequestHandler {
    return async (
        req: express.Request,
        res: express.Response,
        next: express.NextFunction
    ): Promise<void> => {
        const validationOptions = {
            abortEarly: false,
            allowUnknown: true,
            stripUnknown: true
        };

        try {
            const value = await schema.validateAsync(
                req.body,
                validationOptions
            );
            req.body = value;
            next();
        } catch (error:any) {
            // const errors: string[] = [];
            // error.details.forEach((error: Joi.ValidationErrorItem) => {
            //     errors.push(error.message);
            // });
            res.status(400).send({ status: false, message: error.details.length > 0 ? error.details[0].message.replace(/\"/gi,'') : "Unknown error" });
        }
    };
}

export default validationMiddleware;