import passportMiddleware from "@/middleware/passportMiddleware"
import validationMiddleware from "@/middleware/validationMiddleware"
import HttpException from "@/utils/exceptions/httpException"
import Controller from "@/utils/interfaces/controller.interface"
import { NextFunction, Request, Response, Router } from "express"
import IUser from "@/resources/user/user.interface"
import PropertyService from "@/resources/property/property.service"
import IProperty from "@/resources/property/property.interface"
import Validate from "@/resources/property/property.validation"

class PropertyController implements Controller {
    public path = '/properties'
    public router = Router()
    private service = new PropertyService()

    constructor() {
        this.initialiseRoutes()
    }

    private initialiseRoutes(): void {
        this.router.get(
            `${this.path}/`,
            passportMiddleware('jwt'),
            this.getProperties
        )

        this.router.get(
            `${this.path}/my/`,
            passportMiddleware('jwt'),
            this.getMyProperties
        )

        this.router.get(
            `${this.path}/shared/`,
            passportMiddleware('jwt'),
            this.getSharedProperties
        )

        this.router.get(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            this.getProperty
        )

        this.router.post(
            `${this.path}/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.create),
            this.createProperty
        )

        this.router.put(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.update),
            this.updateProperty
        )

        this.router.put(
            `${this.path}/:id/share/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.share),
            this.shareProperty
        )

        this.router.put(
            `${this.path}/:id/hide-show/`,
            passportMiddleware('jwt'),
            this.hideShowProperty
        )

        this.router.delete(
            `${this.path}/:id/image/`,
            passportMiddleware('jwt'),
            this.deletePropertyImage
        )

        this.router.delete(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            this.deleteProperty
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

    private getProperties = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { page, size, search, sort, lng, lat, distance, listingNo, type, city, minPrice, maxPrice, minArea, maxArea, facing, streets, minAge, MaxAge, vilaType, landType, useFor, totalFloors, floorNumber, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, availableFor, extraFeatures, status} = req.query
            const properties = await this.service.getProperties( page, size, search, sort, user, null, null, lng, lat, distance, listingNo, type, city, minPrice, maxPrice, minArea, maxArea, facing, streets, minAge, MaxAge, vilaType, landType, useFor, totalFloors, floorNumber, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, availableFor, extraFeatures, status)
            res.status(200).json(properties)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getMyProperties = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { page, size, search, sort, lng, lat, distance, listingNo, type, city, minPrice, maxPrice, minArea, maxArea, facing, streets, minAge, MaxAge, vilaType, landType, useFor, totalFloors, floorNumber, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, availableFor, extraFeatures, status} = req.query
            const properties = await this.service.getProperties( page, size, search, sort, user, user.id, null, lng, lat, distance, listingNo, type, city, minPrice, maxPrice, minArea, maxArea, facing, streets, minAge, MaxAge, vilaType, landType, useFor, totalFloors, floorNumber, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, availableFor, extraFeatures, status)
            res.status(200).json(properties)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getSharedProperties = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { page, size, search, sort, lng, lat, distance, listingNo, type, city, minPrice, maxPrice, minArea, maxArea, facing, streets, minAge, MaxAge, vilaType, landType, useFor, totalFloors, floorNumber, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, availableFor, extraFeatures, status} = req.query
            const properties = await this.service.getProperties( page, size, search, sort, user, null, user.id, lng, lat, distance, listingNo, type, city, minPrice, maxPrice, minArea, maxArea, facing, streets, minAge, MaxAge, vilaType, landType, useFor, totalFloors, floorNumber, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, availableFor, extraFeatures, status)
            res.status(200).json(properties)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getProperty = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const property = await this.service.getProperty(id,user)
            res.status(200).json(property)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private createProperty = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { location, city, neighbourhood, availableFor, type, price, area, age, northFacing, eastFacing, westFacing, southFacing, vilaType, landType, useFor, floorNumber, totalFloors, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, extraFeatures, coverImage, images, advertisersRole, planNumber, plotNumber, falLicenseNumber, licenseNumber, ownerName, ownerNumber, description, status} = req.body
            const property = await this.service.createProperty(user, location, city, neighbourhood, availableFor, type, price, area, age, northFacing, eastFacing, westFacing, southFacing, vilaType, landType, useFor, floorNumber, totalFloors, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, extraFeatures, coverImage, images, advertisersRole, planNumber, plotNumber, falLicenseNumber, licenseNumber, ownerName, ownerNumber, description, status) as IProperty
            res.status(200).json(property)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private updateProperty = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const { location, city,neighbourhood, availableFor, type, price, area, age, northFacing, eastFacing, westFacing, southFacing, vilaType, landType, useFor, floorNumber, totalFloors, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, extraFeatures, coverImage, images, advertisersRole, planNumber, plotNumber, falLicenseNumber, licenseNumber, ownerName, ownerNumber, description, status} = req.body
            const property = await this.service.updateProperty(id, user, location, city,neighbourhood, availableFor, type, price, area, age, northFacing, eastFacing, westFacing, southFacing, vilaType, landType, useFor, floorNumber, totalFloors, totalBedrooms, totalBathrooms, totalLivingrooms, availableParking, services, extraFeatures, coverImage, images, advertisersRole, planNumber, plotNumber, falLicenseNumber, licenseNumber, ownerName, ownerNumber, description, status) as IProperty
            res.status(200).json(property)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private shareProperty = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const { users, contact } = req.body
            const property = await this.service.shareProperty(id, user, users, contact) as IProperty
            res.status(200).json(property)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private hideShowProperty = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const property = await this.service.hideShowProperty(id, user) as IProperty
            res.status(200).json(property)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private deletePropertyImage = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const { url } = req.query
            const user = req.user as IUser
            const property = await this.service.deletePropertyImage(id, user, url) as IProperty
            res.status(200).json(property)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private deleteProperty = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const property = await this.service.deleteProperty(id, user) as IProperty
            res.status(200).json(property)
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
export default PropertyController