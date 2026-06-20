import userModel from "@/resources/user/user.model"
import User from "@/resources/user/user.interface"
import { PaginateOptions, PaginateResult } from "mongoose"
import twilio from 'twilio';
import fs from 'fs'
import FileService from "@/utils/services/file.service";
import moment from "moment";

class UserService {
    private model = userModel
    private fileService = new FileService()
    private customLabels = { totalDocs: "totalElements", docs: "content", limit: "size", page: "page" }

    public async signUpUser(code:string,mobile:string) : Promise<User | Error> {
        try {
            var user = await this.model.findOne({code:code,mobile:mobile}) as User
            if(!user){
                //throw new Error('Mobile number already registered')
                user = await this.model.create({code, mobile, password:'1234' })
            }
            this.sendVerificationCode(user)
            return user
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async signInUser(code:string,mobile:string) : Promise<User | Error> {
        try {
            var user = await this.model.findOne({code:code,mobile:mobile}) as User
            if(!user){
                // throw new Error('Mobile number not registered')
                user = await this.model.create({code, mobile, password:'1234' })
            }   
            this.sendVerificationCode(user)
            return user
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async getUser(filter:Object) : Promise<User | Error> {
        try {
            return await this.model.findOne(filter) as User
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async updateUserToken(id:string,token:string) : Promise<User | Error> {
        try {
            return await this.model.findByIdAndUpdate(id,{token:token}) as User
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async getUsers(
        page:any = 0,
        size:any = 20,
        search: any,
        sort: any
    ): Promise<PaginateResult<User> | Error> {
        try {
            const options:PaginateOptions = {
                page: +page,
                limit: size,
                sort: sort,
                customLabels: this.customLabels
            }
            return await this.model.paginate({$or: [{email: { $regex: search, $options: "i" }},{mobile: { $regex: search, $options: "i" }},{displayName: { $regex: search, $options: "i" }}], $and:[{isDeleted : {$ne : true}}]},options)
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async getUserProfile(id:string) : Promise<User | Error> {
        try {
            const user = await this.model.findById(id)
            return user != null ? user : new Error('User not found')
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async deleteUser(user:User) : Promise<User | Error>{
        const dateTime = new Date()
        if(!user.role.includes("admin")){
            const updatedUser = await this.model.findByIdAndUpdate(user.id,{mobile: `000${dateTime.getTime()}000${user.mobile}`, isDeleted: true},{new: true})
            return updatedUser != null ? updatedUser : new Error('User not found')
        }else{
            return new Error('Unable to delete admin account')
        }
    }

    public async updateUser(id:string,isBlocked?:boolean,isAdmin?:boolean) : Promise<User | Error>{
        const user = await this.getUser({_id:id}) as User
        if(user){
            if(isBlocked != undefined){
                user.isBlocked = isBlocked
            }
            if(isAdmin != undefined && isAdmin == true && !user.role.includes('admin')){
                user.role.push('admin')
            }else if(isAdmin != undefined && isAdmin == false && user.role.includes('admin')){
                user.role = user.role.filter(element => element != 'admin') as [string]
            }
        }

        const updatedUser = await this.model.findByIdAndUpdate(id,user,{new: true})
        return updatedUser != null ? updatedUser : new Error('User not found')
    }
    
    public async updateProfile(id:string,avatar:string,displayName:string,code:number,mobile:string) : Promise<User | Error>{
        let user = await this.getUser({ code:code, mobile:mobile }) as User
        if(user && user._id != id){
            throw new Error('Mobile already exist')
        }

        let data = {code:code, mobile:mobile, displayName:displayName, avatar:''}
        if(user){
            data.avatar = user.avatar
        }

        if(avatar && !avatar.includes('https://')){
            let base64Data:string = ''
            let mimeType:string = ''
            if(avatar.includes('data:image/png;base64')){
                base64Data = avatar.replace(/^data:image\/png;base64,/, "")
                mimeType = 'png'
            }else if(avatar.includes('data:image/jpg;base64')){
                base64Data = avatar.replace(/^data:image\/jpg;base64,/, "")
                mimeType = 'jpg'
            }else if(avatar.includes('data:image/jpeg;base64')){
                base64Data = avatar.replace(/^data:image\/jpeg;base64,/, "")
                mimeType = 'jpeg'
            }else{
                base64Data = avatar
                mimeType = 'jpg'
            }
            if(base64Data != '' && mimeType != ''){
                const fileWrite = new Promise((success) => {
                    fs.writeFile(`public/avatar_${id}.${mimeType}`, base64Data,'base64', (err) => {
                        if (!err) success(`public/avatar_${id}.${mimeType}`)
                        console.log('Error to file',err)
                    })
                })
                const path = await fileWrite as string
                if(path){
                    data.avatar = await this.fileService.uploadFile(path,`users/${id}/avatar_${Date.now()}.${mimeType}`,data.avatar) as string   
                }
            }
        }
        const updatedUser = await this.model.findByIdAndUpdate(id,data,{new: true}) as User
        return updatedUser != null ? updatedUser.forProfile() : new Error('User not found')
    }

    private async sendVerificationCode(user:User) : Promise<User | Error> {      
        const otp = Math.floor(1000 + Math.random() * 9000)
        // const otp = 1234
        user.password = `${otp}`
        const newUser = await user.save() as User
        if(user.mobile){
            // const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN)
            // twilioClient.messages.create({
            //     from: process.env.TWILIO_FROM,
            //     to: `+${newUser.code}${newUser.mobile}`,
            //     body: `Your verification code is ${otp} for NASIF.`
            // })
            const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN)
            twilioClient.verify.v2.services(process.env.TWILIO_VERIFICATIO_SID ?? "")
                .verifications
                .create({to: `+${newUser.code}${newUser.mobile}`, channel: 'sms'})
                .then(verification => console.log(`OTP Verification service id =  ${verification.sid}`));
        }

        return user
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
                    user : await this.model.countDocuments({createdAt:{$gte: moment(now).subtract(index, 'days').startOf('day').toDate(), $lt: moment(now).subtract(index, 'days').endOf('day').toDate()}}),
                    time : moment(now).subtract(index,'days').toISOString()
                }
                chart.push(summary)
            }
            
            now = new Date()
            let summary = {
                chart: chart,
                totalUser: await this.model.countDocuments({createdAt:{$gte: moment(now).subtract(days, 'days').startOf('day').toDate()}})
            }
            return summary
        }catch (error: any) {
            throw new Error(error.message)
        }  
    }    
}

export default UserService;