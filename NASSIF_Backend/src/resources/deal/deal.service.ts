import FileService from "@/utils/services/file.service"
import dealModel from "@/resources/deal/deal.model"
import IDeal from "@/resources/deal/deal.interface"
import { PaginateOptions, PaginateResult } from "mongoose"
import IUser from "@/resources/user/user.interface"
import fs from 'fs'
import PropertyService from "@/resources/property/property.service"
import IProperty from "@/resources/property/property.interface"
import messageModel from "@/resources/deal/message.model"
import IDealMessage from "@/resources/deal/message.interface"
import SocketService from "@/utils/services/socket.service"
import moment from "moment"
import userModel from "../user/user.model"

class DealService {
    private model = dealModel
    private userModel = userModel
    private messageModel= messageModel
    private fileService = new FileService()
    private propertyService = new PropertyService()
    private customLabels = { totalDocs: "totalElements", docs: "content", limit: "size", page: "page" }

    public async getDeal(
        id: any,
        user: IUser,
    ): Promise<IDeal | Error> {
        try {
            let deal = await this.model.findById(id) as IDeal            
            if(deal.user == user.id){ 
                deal = await this.model.findByIdAndUpdate(id,{userUnreadMsg: 0 }, {new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar']}).populate({ path: "property", model: "Properties", select: ['_id','city','availableFor','type','price','area','coverImage','status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IDeal
            }else if (deal.buyer == user.id){
                deal = await this.model.findByIdAndUpdate(id,{buyerUnreadMsg: 0 }, {new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar']}).populate({ path: "property", model: "Properties", select: ['_id','city','availableFor','type','price','area','coverImage','status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IDeal
            }
            
            return deal.toJSON(user.id)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async getDeals(
        page:any = 0,
        size:any = 20,
        search:any = '',
        sort: any = {'dealNo':1},
        user: IUser,
        status: any,
        archived: any
    ): Promise<PaginateResult<IDeal> | Error> {
        try {
            const options:PaginateOptions = {
                page: page,
                limit: size,
                sort: sort,
                customLabels: this.customLabels,
                populate: [
                    {
                        path: "user",
                        model: "User",
                        select: ["_id", "displayName", "avatar", "mobile"]
                    },
                    {
                        path: "buyer",
                        model: "User",
                        select: ["_id", "displayName", "avatar", "mobile"]
                    },
                    {
                        path: "property",
                        model: "Properties",
                        select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']
                    },
                    {
                        path: "lastMessage",
                        model: "DealMessages",
                        select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]
                    }
                ]
            }
            let andCondition = []
            andCondition.push({isDeleted: false})
            if(status){
                andCondition.push({status: status})
            }

            if(archived){
                const isArchived = archived === true || archived === 'true';
                if(isArchived){
                    andCondition.push({ archivedBy: { $in: user.id }})
                }else{
                    andCondition.push({ archivedBy: { $nin: user.id }})
                }
            }

            andCondition.push({ $or: [{buyer: user.id }, {user: user.id}] })

            let query: any = {
            $and: [
                {
                    $or: [
                        // { city: { $regex: search, $options: "i" } },
                        // { advertisersRole: { $regex: search, $options: "i" } },
                        // { planNumber: { $regex: search, $options: "i" } },
                        // { plotNumber: { $regex: search, $options: "i" } },
                        // { falLicenseNumber: { $regex: search, $options: "i" } },
                        // { licenseNumber: { $regex: search, $options: "i" } },
                        // { ownerNumber: { $regex: search, $options: "i" } },
                        // { description: { $regex: search, $options: "i" } }
                    ]
                },
                ...andCondition
                ]
            };

            let deals: PaginateResult<any> = await this.model.paginate(query,options)
            if(Array.isArray(deals.content)){
                for (let index = 0; index < deals.content.length; index++) {
                    deals.content[index] = deals.content[index].toList(user.id)
                }
            }
            return deals
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async createDeal(
        user: IUser,
        propertyId: string,
        buyerId: string,
        contact?: string
    ): Promise<IDeal | Error> {
        try {
            const property = await this.propertyService.getProperty(propertyId,user) as IProperty
            if(!property || property.user != user.id || property.isDeleted){
                throw new Error('Property not found')
            }

            if(contact){
                const registeredUser = await this.userModel.findOne({mobile:{$in: contact}}) as IUser
                if(registeredUser){
                    buyerId = registeredUser.id
                }else{
                    throw new Error('User not registered')
                }
            }

            let deal = await this.model.findOne({property:propertyId,user:user.id,buyer:buyerId,isDeleted:false}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "property", model: "Properties", select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "fileName", "createdAt"]}) as IDeal
            if(!deal){
                deal = await this.model.create({
                    property: propertyId,
                    user:user.id,
                    buyer:buyerId,
                })
                const message = await this.messageModel.create({
                    deal: deal.id,
                    sender: user.id,
                    type: 'Title',
                    text: `Deal started.`
                })
                deal = await this.model.findByIdAndUpdate(deal.id,{lastMessage:message,buyerUnreadMsg:1},{new:true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "property", model: "Properties", select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "fileName", "createdAt"]}) as IDeal
            }
            return deal.toJSON(user.id)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async updateDeal(
        user: IUser,
        id: string,
        name: string
    ): Promise<IDeal | Error> {
        try {
            let deal = await this.model.findById(id) as IDeal
            if(!deal || deal.user != user.id){
                throw new Error('Deal not found')     
            }
            deal = await this.model.findByIdAndUpdate(deal.id,{name:name},{new:true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "property", model: "Properties", select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "fileName", "createdAt"]}) as IDeal
            return deal.toJSON(user.id)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async changeDealStatus(
        id: any,
        newSubStatus: any,
        user: IUser,
    ): Promise<IDeal | Error> {
        try {
            let deal = await this.model.findById(id) as IDeal
            if(!isNaN(newSubStatus) && (deal.user == user.id || deal.buyer == user.id) && !deal.isDeleted){
                if(Number(newSubStatus) != 0 && Number(newSubStatus) == deal.subStatus){
                    deal.subStatus = deal.subStatus - 1
                }else if(Number(newSubStatus) != 0 && Number(newSubStatus) == (deal.subStatus + 1)){
                    deal.subStatus = deal.subStatus + 1
                }else{
                    throw new Error('Invalid deal status')
                }

                if(deal.subStatus > 2){
                    deal.status = 'Completion'
                }else if(deal.subStatus > 1){
                    deal.status = 'Negotiations'
                }else {
                    deal.status = 'Inquiries'
                } 

                deal = await this.model.findByIdAndUpdate(id,{subStatus: deal.subStatus, status: deal.status}, {new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "property", model: "Properties", select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "fileName", "createdAt"]}) as IDeal
                return deal.toJSON(user.id)
            }
            throw new Error('Deal not found')
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async archivedDeal(
        id: any,
        user: IUser,
    ): Promise<IDeal | Error> {
        try {
            let deal = await this.model.findById(id) as IDeal
            console.log(deal)
            if((deal.user == user.id || deal.buyer == user.id) && !deal.isDeleted){
                if(!deal.archivedBy?.includes(user.id)){
                    deal.archivedBy?.push(user.id)
                }
                deal = await this.model.findByIdAndUpdate(id,{archivedBy: deal.archivedBy}, {new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "property", model: "Properties", select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "fileName", "createdAt"]}) as IDeal
                return deal.toJSON(user.id)
            }
            throw new Error('Deal not found')
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async deleteDeal(
        id: any,
        user: IUser,
    ): Promise<IDeal | Error> {
        try {
            let deal = await this.model.findById(id) as IDeal
            if(deal.user == user.id && !deal.isDeleted){
                deal = await this.model.findByIdAndUpdate(id,{isDeleted: true }, {new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "property", model: "Properties", select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "fileName", "createdAt"]}) as IDeal
                return deal.toJSON(user.id)
            }
            throw new Error('Deal not found')
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async exitDeal(
        id: any,
        user: IUser,
    ): Promise<IDeal | Error> {
        try {
            let deal = await this.model.findById(id) as IDeal
            if(deal && (deal.user == user.id || deal.buyer == user.id)){
                if(deal.user == user.id){
                    deal = await this.model.findByIdAndUpdate(id,{userExit:true}, {new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "property", model: "Properties", select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "fileName", "createdAt"]}) as IDeal
                }else if (deal.buyer == user.id){
                    deal = await this.model.findByIdAndUpdate(id,{buyerExit:true}, {new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "buyer", model: "User", select: ['_id','displayName','avatar','mobile']}).populate({ path: "property", model: "Properties", select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']}).populate({ path: "lastMessage", model: "DealMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "fileName", "createdAt"]}) as IDeal
                }
                return deal.toJSON(user.id)
            }
            throw new Error('Deal not found')
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async createDealMessage(
        message: any
    ): Promise<IDealMessage | Error> {
        try {
            let deal = await this.model.findById(message.deal) as IDeal
            if(deal.user == message.sender || deal.buyer == message.sender){
                let dealMessage = await this.messageModel.create({
                    deal: deal.id,
                    sender: message.sender,
                    type: message.type,
                    text: message.text,
                    fileType: message.fileType,
                    fileName: message.fileName,
                }) as IDealMessage

                if(message.file && message.type  == 'Image'){
                    let fileName = `${deal.id}_${dealMessage.id}_${message.fileName}`
                    dealMessage.file = this.getUrl(message.file,fileName,deal.id)
                    this.uploadFile(message.file,fileName,deal.id)
                }else if(message.file && message.type  == 'File' && message.fileType  == 'pdf'){
                    let fileName = `${deal.id}_${dealMessage.id}_${message.fileName}`
                    dealMessage.file = this.getUrl(message.file,fileName,deal.id)
                    this.uploadFile(message.file,fileName,deal.id)
                }
                dealMessage = await this.messageModel.findByIdAndUpdate(dealMessage.id,{file: dealMessage.file},{new: true}).populate({path: "sender", model: "User", select: ["_id", "displayName", "avatar", "mobile"]}) as IDealMessage
                
                let buyerUnreadMsg = deal.buyerUnreadMsg
                let userUnreadMsg = deal.userUnreadMsg
                if(deal.user == message.sender){
                    userUnreadMsg = 0
                    buyerUnreadMsg = buyerUnreadMsg + 1
                }else if(deal.buyer == message.sender){
                    userUnreadMsg = userUnreadMsg + 1
                    buyerUnreadMsg = 0
                }

                await this.model.findByIdAndUpdate(deal.id,{lastMessage:dealMessage, userUnreadMsg:userUnreadMsg, buyerUnreadMsg:buyerUnreadMsg},{new:true}) as IDeal
                SocketService.EmitDealMessage(dealMessage);
                return dealMessage
            }
            throw new Error("Deal not found");
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async getDealMessages(
        page: any = 0,
        size: any = 20,
        search: any = '',
        sort: any,
        user: IUser,
        dealId: any
    ): Promise<PaginateResult<IDealMessage> | Error> {
        try {
            const options:PaginateOptions = {
                page: page,
                limit: size,
                sort: {'createdAt':-1},
                customLabels: this.customLabels,
                populate: [
                    {
                        path: "sender",
                        model: "User",
                        select: ["_id", "displayName", "avatar", "mobile"]
                    }
                ]
            }
            let andCondition = []
            andCondition.push({deal: dealId})
            andCondition.push({isDeleted: false})
            
            let query: any = {
            $and: [
                {
                    $or: [
                        // { city: { $regex: search, $options: "i" } },
                        // { advertisersRole: { $regex: search, $options: "i" } },
                        // { planNumber: { $regex: search, $options: "i" } },
                    ]
                },
                ...andCondition
                ]
            };

            let dealMessages: PaginateResult<any> = await this.messageModel.paginate(query,options)
            if(Array.isArray(dealMessages.content)){
                for (let index = 0; index < dealMessages.content.length; index++) {
                    dealMessages.content[index] = dealMessages.content[index].toList(user.id)
                }
            }
            return dealMessages
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    private getUrl(image:string,type:string,id:string){
        if(image.includes('data:image/png;base64')){
            return `https://${ process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/deal/${id}/messages/${type}`
        }else if(image.includes('data:image/jpeg;base64')){
            return `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/deal/${id}/messages/${type}`
        }else if(image.includes('data:application/pdf;base64')){
            return `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/deal/${id}/messages/${type}`
        }else{
            return `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/deal/${id}/messages/${type}`
        }
    }

    private async uploadFile(image:string,type:string,id:string){
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
        }else if(image.includes('data:application/pdf;base64')){
            base64Data = image.replace(/^data:application\/pdf;base64,/, "")
            mimeType = 'pdf'
        }else{
            base64Data = image
            mimeType = 'jpg'
        }
        if(base64Data != '' && mimeType != ''){
            let imageName = `deals_${id}_${type}`
            const fileWrite = new Promise((success) => {
                fs.writeFile(`public/${imageName}`, base64Data,'base64', (err) => {
                    if (!err) success(`public/${imageName}`)
                })
            })
            const path = await fileWrite as string
            if(path){
                return await this.fileService.uploadFile(path,`deal/${id}/messages/${type}`) as string   
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
                    deals : await this.model.countDocuments({createdAt:{$gte: moment(now).subtract(index, 'days').startOf('day').toDate(), $lt: moment(now).subtract(index, 'days').endOf('day').toDate()}}),
                    time : moment(now).subtract(index,'days').toISOString()
                }
                chart.push(summary)
            }
            
            now = new Date()
            let summary = {
                chart: chart,
                totalDeals: await this.model.countDocuments({createdAt:{$gte: moment(now).subtract(days, 'days').startOf('day').toDate()}})
            }
            return summary
        }catch (error: any) {
            throw new Error(error.message)
        }  
    }    
}
export default DealService