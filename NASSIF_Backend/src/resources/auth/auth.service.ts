import Auth from "@/resources/auth/auth.interface";
import Jwt from "jsonwebtoken";
import IUser from "@/resources/user/user.interface";
import passport from "@/utils/passport";
import UserService from "@/resources/user/user.service";
import twilio from 'twilio';

class AuthService {
    private userService = new UserService()

    public async createToken(user:IUser): Promise<Auth | Error> {
        const { JWT_SECRET } = process.env
        try {
            const token = Jwt.sign({ id: user._id, authority: user.role, code: user.code, mobile: user.mobile, topic: user._id}, `${JWT_SECRET}`)
            const auth:Auth = {
                userId: user._id,
                accessToken: token,
                type: "Bearer",
                mobile: user.mobile,
                code: user.code,
                topic: user._id,
                isNew: user.displayName ? false : true
            } as Auth
            return auth
        }catch (error: any) {
            throw new Error(error.message)
        }        
    }

    public async signUpUser(code:string, mobile: string): Promise<IUser | Error> {
        try {
            return await this.userService.signUpUser(code, mobile)
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async signInUser(code:string, mobile: string): Promise<IUser | Error> {
        try {
            return await this.userService.signInUser(code, mobile)
        } catch (error: any) {
            throw new Error(error.message)
        }
    }


    public async verifyUser(code:string, mobile: string, otp: string): Promise<Auth | Error> { 
        try {
            const user = await this.userService.getUser({code:code, mobile:mobile}) as IUser
            if(!user){
                throw new Error('Mobile number nof tound')
            }  
            const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN)
            return twilioClient.verify.v2.services(process.env.TWILIO_VERIFICATIO_SID ?? "")
                .verificationChecks
                .create({to: `+${code}${mobile}`, code: otp})
                .then(async verification_check => {
                    if(verification_check.valid){
                        let response =  await this.createToken(user) as Auth
                        await this.userService.updateUserToken(user.id,response.accessToken)
                        return response
                    }else{
                        throw new Error("Invalid OTP")
                    }
                })
                .catch(error => {
                    throw new Error("Invalid OTP")
                })
        } catch (error: any) {
            throw new Error(error.message)
        }
    }

}
export default AuthService;