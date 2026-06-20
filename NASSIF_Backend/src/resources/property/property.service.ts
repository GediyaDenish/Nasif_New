import FileService from "@/utils/services/file.service"
import propertyModel from "@/resources/property/property.model"
import IProperty from "@/resources/property/property.interface"
import { PaginateOptions, PaginateResult } from "mongoose"
import IUser from "@/resources/user/user.interface"
import fs from 'fs'
import ChatService from "../chat/chat.service"
import IChat from "../chat/chat.interface"
import moment from "moment"
import userModel from "../user/user.model"

class PropertyService {

    private model = propertyModel
    private userModel = userModel
    private fileService = new FileService()
    private charService = new ChatService()
    private customLabels = { totalDocs: "totalElements", docs: "content", limit: "size", page: "page" }

    public async getProperty(
        id: any,
        user: IUser,
    ): Promise<IProperty | Error> {
        try {
            const property = await this.model.findById(id).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}) as IProperty
            return property.toJSON(user.id)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async getProperties(
        page:any = 0,
        size:any = 20,
        search:any = '',
        sort: any = {'price':1},
        user: IUser,
        onlyUser: any,
        onlyShared: any,
        lng: any,
        lat: any,
        distance: any = 5000,
        listingNo: any,
        type: any,
        city: any,
        minPrice: any = 0,
        maxPrice: any,
        minArea: any = 0,
        maxArea: any,
        facing: any,
        streets: any = 0,
        minAge: any = 0,
        maxAge: any,
        vilaType: any,
        landType: any,
        useFor: any,
        totalFloors: any,
        floorNumber: any,
        totalBedrooms: any,
        totalBathrooms: any,
        totalLivingrooms: any,
        availableParking: any,
        services: any,
        availableFor: any,
        extraFeatures: any,
        status: any
    ): Promise<PaginateResult<IProperty> | Error> {
        try {
            const options:PaginateOptions = {
                page: page,
                limit: size,
                sort: sort,
                customLabels: this.customLabels
            }

            let andCondition = []
            if(lat && lng){
                andCondition.push({
                    location: {
                        $geoWithin: {
                            $centerSphere: [
                                [lng, lat],
                                (distance / 1000) / 6378.1
                            ]
                        }
                    }
                })
            }

            andCondition.push({isDeleted: false})

            if(onlyUser){
                andCondition.push({user: onlyUser})
            }

            if(onlyShared){
                andCondition.push({ $or: [{sharedWith: { $in: onlyShared } }, {user: user.id}] })
                andCondition.push({ $and: [{sharedHideFor: { $nin: user.id }}] })
            }
                            
            if(listingNo && !isNaN(listingNo)){
                andCondition.push({listingNo: Number(listingNo)})
            }            

            if(type){
                andCondition.push({type:type})
            }

            if(city){
                andCondition.push({type:type})
            }

            if (minPrice && maxPrice) {
                andCondition.push({ price: { $gte: minPrice, $lte: maxPrice } })
            }

            if(minArea && maxArea){
                andCondition.push({ area: { $gte: minArea, $lte: maxArea } })
            }

            if(facing){
                for (const item of facing.toLowerCase().split(",")) {
                    if (item.trim() == 'north') {
                        andCondition.push({ northFacing: { $gte: 1 } })
                    }else if(item.trim() == 'east') {
                        andCondition.push({ eastFacing: { $gte: 1 } })
                    }else if(item.trim() == 'west') {
                        andCondition.push({ westFacing: { $gte: 1 } })
                    }else if(item.trim() == 'south') {
                        andCondition.push({ southFacing: { $gte: 1 } })
                    }
                }
            }

            if(streets > 0){
                andCondition.push({ streets: { $gte: streets } })
            }

            if(minAge && maxAge){
                andCondition.push({ age: { $gte: minAge, $lte: maxAge } })
            }

            if(vilaType){
                andCondition.push({ vilaType: { $regex: vilaType, $options: "i" } })
            }

            if(landType){
                andCondition.push({ landType: { $regex: landType, $options: "i" } })
            }

            if(useFor){
                andCondition.push({ useFor: { $regex: useFor, $options: "i" } })
            }
            
            if(totalFloors > 0){
                andCondition.push({ totalFloors: { $gte: totalFloors } })
            }

            if(floorNumber > 0){
                andCondition.push({ floorNumber: { $gte: floorNumber } })
            }

            if(totalBedrooms > 0){
                andCondition.push({ totalBedrooms: { $gte: totalBedrooms } })
            }

            if(totalBathrooms > 0){
                andCondition.push({ totalBathrooms: { $gte: totalBathrooms } })
            }

            if(totalLivingrooms > 0){
                andCondition.push({ totalLivingrooms: { $gte: totalLivingrooms } })
            }

            if(availableParking > 0){
                andCondition.push({ availableParking: { $gte: availableParking } })
            }

            if(services){
                const serviceCondition = []
                for (const item of services.toLowerCase().split(",")) {
                    serviceCondition.push({ services: { $regex: item.trim(), $options: "i" } })
                }
                if(serviceCondition.length > 0){
                    andCondition.push({ $or: serviceCondition });
                }
            }

            if(availableFor){
                andCondition.push({ availableFor: { $regex: availableFor, $options: "i" } })
            }

            if(extraFeatures){
                const extraFeaturesCondition = []
                for (const item of extraFeatures.toLowerCase().split(",")) {
                    extraFeaturesCondition.push({ extraFeatures: { $regex: item.trim(), $options: "i" } })
                }
                if(extraFeaturesCondition.length > 0){
                    andCondition.push({ $or: extraFeaturesCondition })
                }
            }

            if(status){
                andCondition.push({ status: { $regex: status, $options: "i" } })
            }
           

            let query: any = {
            $and: [
                {
                    $or: [
                        { city: { $regex: search, $options: "i" } },
                        { advertisersRole: { $regex: search, $options: "i" } },
                        { planNumber: { $regex: search, $options: "i" } },
                        { plotNumber: { $regex: search, $options: "i" } },
                        { falLicenseNumber: { $regex: search, $options: "i" } },
                        { licenseNumber: { $regex: search, $options: "i" } },
                        { ownerNumber: { $regex: search, $options: "i" } },
                        { description: { $regex: search, $options: "i" } }
                    ]
                },
                ...andCondition
                ]
            };

            let properties: PaginateResult<any> = await this.model.paginate(query,options)
            if(Array.isArray(properties.content)){
                for (let index = 0; index < properties.content.length; index++) {
                    properties.content[index] = properties.content[index].toList(user.id)
                }
            }
            return properties
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async createProperty(
        user: IUser,
        location: object,
        city: string,
        neighbourhood: string,
        availableFor: string,
        type: string,
        price: number,
        area: number,
        age: number,
        northFacing: number,
        eastFacing: number,
        westFacing: number,
        southFacing: number,
        vilaType: string,
        landType: string,
        useFor: [string],
        floorNumber: number,
        totalFloors: number,
        totalBedrooms: number,
        totalBathrooms: number,
        totalLivingrooms: number,
        availableParking: number,
        services: [string],
        extraFeatures: [string],
        coverImage: string,
        images?: [string],
        advertisersRole?: string,
        planNumber?: string,
        plotNumber?: string,
        falLicenseNumber?: string,
        licenseNumber?: string,
        ownerName?: string,
        ownerNumber?: string,
        description?: string,
        status?: string
    ): Promise<IProperty | Error> {
        try {
            let property = await this.model.create({
                user:user.id,
                location:location,
                city: city,
                neighbourhood: neighbourhood,
                availableFor: availableFor,
                type: type,
                price: price,
                area: area,
                age: age,
                northFacing: northFacing,
                eastFacing: eastFacing,
                westFacing: westFacing,
                southFacing: southFacing,
                streets: 0 + (northFacing ? 1 : 0) + (eastFacing ? 1 : 0) + (westFacing ? 1 : 0) + (southFacing ? 1 : 0),
                vilaType: vilaType,
                landType: landType,
                useFor: useFor,
                floorNumber: floorNumber,
                totalFloors: totalFloors,
                totalBedrooms: totalBedrooms,
                totalBathrooms: totalBathrooms,
                totalLivingrooms: totalLivingrooms,
                availableParking: availableParking,
                services: services,
                extraFeatures: extraFeatures,
                advertisersRole: advertisersRole,
                planNumber: planNumber,
                plotNumber: plotNumber,
                falLicenseNumber: falLicenseNumber,
                licenseNumber: licenseNumber,
                ownerName: ownerName,
                ownerNumber: ownerNumber,
                description: description,
                status: status
            }) 
            if(coverImage){
                let imageType = `cover_${Date.now()}`
                property.coverImage = this.getUrl(coverImage,imageType,property.id)
                this.uploadImage(coverImage,imageType,property.id)
            }
            if(images && images.length > 0){
                for (let index = 0; index < images.length; index++) {
                    if(!images[index].includes('https://')){
                        let imageType = `other_${index}_${Date.now()}`
                        property.images?.push(this.getUrl(images[index],imageType,property.id))
                        this.uploadImage(images[index],imageType,property.id)
                    }
                }
            }
            const updated = await this.model.findByIdAndUpdate(property.id,{coverImage: property.coverImage, images:property.images},{new: true})
            return updated != null ? updated.toList(user.id) : property.toList(user.id)
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async updateProperty(
        id: string,
        user: IUser,
        location: {
            coordinates:[number]
        },
        city: string,
        neighbourhood: string,
        availableFor: string,
        type: string,
        price: number,
        area: number,
        age: number,
        northFacing: number,
        eastFacing: number,
        westFacing: number,
        southFacing: number,
        vilaType: string,
        landType: string,
        useFor: [string],
        floorNumber: number,
        totalFloors: number,
        totalBedrooms: number,
        totalBathrooms: number,
        totalLivingrooms: number,
        availableParking: number,
        services: [string],
        extraFeatures: [string],
        coverImage: string,
        images?: [string],
        advertisersRole?: string,
        planNumber?: string,
        plotNumber?: string,
        falLicenseNumber?: string,
        licenseNumber?: string,
        ownerName?: string,
        ownerNumber?: string,
        description?: string,
        status?: string
    ): Promise<IProperty | Error> {
        try {

            const property = await this.model.findById(id) as IProperty
            if(property && property.user == user.id){
                // property.location.coordinates = location.coordinates == null || location.coordinates == undefined ? property.location.coordinates : location.coordinates
                // property.city = city == null || city == undefined ? property.city : city
                // property.neighbourhood = neighbourhood == null || neighbourhood == undefined ? property.neighbourhood : neighbourhood
                // property.availableFor = availableFor == null || availableFor == undefined ? property.availableFor : availableFor
                // property.type = type == null || type == undefined ? property.type : type
                // property.price = price == null || price == undefined ? property.price : price
                // property.age = age == null || price == undefined ? property.age : age
                // property.area = area == null || area == undefined ? property.area : area
                // property.northFacing = northFacing == null || northFacing == undefined ? property.northFacing : northFacing
                // property.eastFacing = eastFacing == null || eastFacing == undefined ? property.eastFacing : eastFacing
                // property.westFacing = westFacing == null || westFacing == undefined ? property.westFacing : westFacing
                // property.southFacing = southFacing == null || southFacing == undefined ? property.southFacing : southFacing
                // property.streets = 0 + (property.northFacing ? 1 : 0) + (property.eastFacing ? 1 : 0) + (property.westFacing ? 1 : 0) + (property.southFacing ? 1 : 0),
                // property.vilaType = vilaType == null || vilaType == undefined ? property.vilaType : vilaType
                // property.landType = landType == null || landType == undefined ? property.landType : landType
                // property.useFor = useFor == null || useFor == undefined ? property.useFor : useFor
                // property.floorNumber = floorNumber == null || floorNumber == undefined ? property.floorNumber : floorNumber
                // property.totalFloors = totalFloors == null || totalFloors == undefined ? property.totalFloors : totalFloors
                // property.totalBedrooms = totalBedrooms == null || totalBedrooms == undefined ? property.totalBedrooms : totalBedrooms
                // property.totalBathrooms = totalBathrooms == null || totalBathrooms == undefined ? property.totalBathrooms : totalBathrooms
                // property.totalLivingrooms = totalLivingrooms == null || totalLivingrooms == undefined ? property.totalLivingrooms : totalLivingrooms
                // property.availableParking = availableParking == null || availableParking == undefined ? property.availableParking : availableParking
                // property.services = services == null || services == undefined ? property.services : services
                // property.extraFeatures = extraFeatures == null || extraFeatures == undefined ? property.extraFeatures : extraFeatures
                // property.advertisersRole = advertisersRole == null || advertisersRole == undefined ? property.advertisersRole : advertisersRole
                // property.planNumber = planNumber == null || planNumber == undefined ? property.planNumber : planNumber
                // property.plotNumber = plotNumber == null || plotNumber == undefined ? property.plotNumber : plotNumber
                // property.falLicenseNumber = falLicenseNumber == null || falLicenseNumber == undefined ? property.falLicenseNumber : falLicenseNumber
                // property.licenseNumber = licenseNumber == null || licenseNumber == undefined ? property.licenseNumber : licenseNumber
                // property.ownerName = ownerName == null || ownerName == undefined ? property.ownerName : ownerName
                // property.ownerNumber = ownerNumber == null || ownerNumber == undefined ? property.ownerNumber : ownerNumber
                // property.description = description == null || description == undefined ? property.description : description

                property.location.coordinates = location.coordinates == null || location.coordinates == undefined ? property.location.coordinates : location.coordinates
                property.city = city == null || city == undefined ? property.city : city
                property.neighbourhood = neighbourhood == null || neighbourhood == undefined ? property.neighbourhood : neighbourhood
                property.availableFor = availableFor == null || availableFor == undefined ? property.availableFor : availableFor
                property.type = type == null || type == undefined ? property.type : type
                property.price = price == null || price == undefined ? property.price : price
                property.age = age == null || price == undefined ? property.age : age
                property.area = area == null || area == undefined ? property.area : area
                property.northFacing = northFacing == null || northFacing == undefined ? property.northFacing : northFacing
                property.eastFacing = eastFacing == null || eastFacing == undefined ? property.eastFacing : eastFacing
                property.westFacing = westFacing == null || westFacing == undefined ? property.westFacing : westFacing
                property.southFacing = southFacing == null || southFacing == undefined ? property.southFacing : southFacing
                property.streets = 0 + (property.northFacing ? 1 : 0) + (property.eastFacing ? 1 : 0) + (property.westFacing ? 1 : 0) + (property.southFacing ? 1 : 0),
                property.vilaType = vilaType == null || vilaType == undefined ? '' : vilaType
                property.landType = landType == null || landType == undefined ? '' : landType
                property.useFor = useFor == null || useFor == undefined ? [] : useFor
                property.floorNumber = floorNumber == null || floorNumber == undefined ? 0 : floorNumber
                property.totalFloors = totalFloors == null || totalFloors == undefined ? 0 : totalFloors
                property.totalBedrooms = totalBedrooms == null || totalBedrooms == undefined ? 0 : totalBedrooms
                property.totalBathrooms = totalBathrooms == null || totalBathrooms == undefined ? 0 : totalBathrooms
                property.totalLivingrooms = totalLivingrooms == null || totalLivingrooms == undefined ? 0 : totalLivingrooms
                property.availableParking = availableParking == null || availableParking == undefined ? 0 : availableParking
                property.services = services == null || services == undefined ? [] : services
                property.extraFeatures = extraFeatures == null || extraFeatures == undefined ? [] : extraFeatures
                property.advertisersRole = advertisersRole == null || advertisersRole == undefined ? '' : advertisersRole
                property.planNumber = planNumber == null || planNumber == undefined ? '' : planNumber
                property.plotNumber = plotNumber == null || plotNumber == undefined ? '' : plotNumber
                property.falLicenseNumber = falLicenseNumber == null || falLicenseNumber == undefined ? '' : falLicenseNumber
                property.licenseNumber = licenseNumber == null || licenseNumber == undefined ? '' : licenseNumber
                property.ownerName = ownerName == null || ownerName == undefined ? '' : ownerName
                property.ownerNumber = ownerNumber == null || ownerNumber == undefined ? '' : ownerNumber
                property.description = description == null || description == undefined ? '' : description
                property.status = status == null || status == undefined ? property.status : status

                let updated = await this.model.findByIdAndUpdate(property.id,property,{new: true})
                
                if(coverImage && !coverImage.includes('https://')){
                    const oldCoverImage = property.coverImage 
                    const imageType = `cover_${Date.now()}`
                    property.coverImage = this.getUrl(coverImage,imageType,property.id)
                    this.uploadImage(coverImage,imageType,property.id)
                    await this.fileService.deleteS3File(oldCoverImage)
                }
                if(images && images.length > 0){
                    let imageType = `other_${Date.now()}`
                    for (let index = 0; index < images.length; index++) {
                        if(!images[index].includes('https://')){
                            imageType = `other_${index}_${Date.now()}`
                            property.images?.push(this.getUrl(images[index],imageType,property.id))
                            this.uploadImage(images[index],imageType,property.id)
                        }
                    }
                }
                updated = await this.model.findByIdAndUpdate(property.id,{coverImage: property.coverImage, images:property.images},{new: true})
                return updated != null ? updated.toList(user.id) : property.toList(user.id)
            }
            throw new Error("Property not found")
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async shareProperty(
        id: any,
        user: IUser,
        users: string[],
        contact?: string
    ): Promise<IProperty | Error> {
        try {
            let property = await this.model.findById(id) as IProperty
            // if(property && property.user == user.id){
                if(contact){
                    const registeredUser = await this.userModel.findOne({mobile:{$in: contact}}) as IUser
                    if(registeredUser){
                        if(!property.sharedWith) {
                            property.sharedWith = []
                        }
                        if (!property.sharedWith?.includes(registeredUser.id) && registeredUser.id != user.id) {
                            property.sharedWith.push(registeredUser.id)
                        }
                    }else{
                        throw new Error('User not registered')
                    }
                }else if(users){
                    if(!property.sharedWith) {
                        property.sharedWith = []
                    }
                    for(const userId of users){
                        if (!property.sharedWith?.includes(userId) && user.id != userId) {
                             property.sharedWith.push(userId)
                        }
                    }
                }
                property.sharedWith = [...new Set(property.sharedWith)];
                property = await this.model.findByIdAndUpdate(property.id,{sharedWith:property.sharedWith},{new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar']}) as IProperty
                if(contact){
                    const registeredUser = await this.userModel.findOne({mobile:{$in: contact}}) as IUser
                    if(registeredUser){
                        let members = []
                        members.push(registeredUser.id)
                        let chat = await this.charService.createChat(user,undefined,undefined,undefined,[],[],members,undefined,property.id) as IChat
                        property.chat = chat?.id;
                    }
                }else if(users){
                    users.forEach(async (member) => {
                        let members = []
                        members.push(member)
                        let chat = await this.charService.createChat(user,undefined,undefined,undefined,[],[],members,undefined,property.id) as IChat
                        property.chat = chat?.id;
                    });
                }
                return property.toJSON(user.id)
            // }
            // throw new Error("Property not found")
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async hideShowProperty(
        id: any,
        user: IUser
    ): Promise<IProperty | Error> {
        try {
            let property = await this.model.findById(id) as IProperty
            if(!property) { throw new Error("Property not found") }
            let isHidden = property.sharedHideFor?.includes(user.id)
            if(!property.sharedHideFor) {
                property.sharedHideFor = []
                property.sharedHideFor.push(user.id)
            }else if(isHidden){
                property.sharedHideFor = property.sharedHideFor.filter(i => i != user.id)
            }else{
                property.sharedHideFor.push(user.id)
            }
            property = await this.model.findByIdAndUpdate(property.id,{sharedHideFor: property.sharedHideFor},{new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar']}) as IProperty
            return property.toJSON(user.id)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async deletePropertyImage(
        id: any,
        user: IUser,
        url: any
    ): Promise<IProperty | Error> {
        try {
            let property = await this.model.findById(id) as IProperty
            if(property && property.user == user.id){
                if(url){
                    await this.fileService.deleteS3File(url)
                    property.images = property.images?.filter(item => item !== url);
                }
                property = await this.model.findByIdAndUpdate(property.id,{images:property.images},{new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}) as IProperty
                return property.toJSON(user.id)
            }
            throw new Error("Property not found")
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async deleteProperty(
        id: any,
        user: IUser
    ): Promise<IProperty | Error> {
        try {
            let property = await this.model.findById(id) as IProperty
            if(property && property.user == user.id){
                property = await this.model.findByIdAndUpdate(property.id,{isDeleted: true},{new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}) as IProperty
                return property.toJSON(user.id)
            }
            throw new Error("Property not found")
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    private getUrl(image:string,type:string,id:string){
        if(image.includes('data:image/png;base64')){
            return `https://${ process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/properties/${id}/${type}.png`
        }else if(image.includes('data:image/jpeg;base64')){
            return `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/properties/${id}/${type}.jpeg`
        }else{
            return `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/properties/${id}/${type}.jpg`
        }
    }

    private async uploadImage(image:string,type:string,id:string){
        let base64Data:string = ''
        let mimeType:string = ''
        if(image.includes('data:image/png;base64')){
            base64Data = image.replace(/^data:image\/png;base64,/, "")
            mimeType = 'png'
        }else if(image.includes('data:image/jpg;base64')){
            base64Data = image.replace(/^data:image\/jpg;base64,/, "")
            mimeType = 'jpg'
        }else if(image.includes('data:image/jpeg;base64')){
            base64Data = image.replace(/^data:image\/jpeg;base64,/, "")
            mimeType = 'jpeg'
        }else{
            base64Data = image
            mimeType = 'jpg'
        }
        if(base64Data != '' && mimeType != ''){
            let imageName = `properties_${type}_${id}.${mimeType}`
            const fileWrite = new Promise((success) => {
                fs.writeFile(`public/${imageName}`, base64Data,'base64', (err) => {
                    if (!err) success(`public/${imageName}`)
                })
            })
            const path = await fileWrite as string
            if(path){
                return await this.fileService.uploadFile(path,`properties/${id}/${type}.${mimeType}`) as string   
            }
            return null
        }
    }

    public async getCounts(days:number){
        try {
            let now = new Date()
            const total = await this.model.countDocuments({createdAt:{$gte: moment(now).subtract(days, 'days').startOf('day').toDate()}})
            return {status:`In last ${days} days`,total:total}
        }catch (error: any) {
            throw new Error(error.message)
        }  
    }

    public async getDaysSummary(days:number){
        try {
            let now = new Date()

            let chart:any[] = []

            for (let index = days; index >= 0; index--) {
                let summary = {
                    property : await this.model.countDocuments({createdAt:{$gte: moment(now).subtract(index, 'days').startOf('day').toDate(), $lt: moment(now).subtract(index, 'days').endOf('day').toDate()}}),
                    time : moment(now).subtract(index,'days').toISOString()
                }
                chart.push(summary)
            }
            
            now = new Date()
            let summary = {
                chart: chart,
                totalProperty: await this.model.countDocuments({createdAt:{$gte: moment(now).subtract(days, 'days').startOf('day').toDate()}})
            }
            return summary
        }catch (error: any) {
            throw new Error(error.message)
        }  
    }    
}
export default PropertyService