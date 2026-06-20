import User from '@/resources/user/user.interface'
import userModel from '@/resources/user/user.model'
import passport, { use } from 'passport'
import passportJwt from 'passport-jwt'
import passportLocal from "passport-local"

const LocalStrategy = passportLocal.Strategy
const JwtStrategy = passportJwt.Strategy
const ExtractJwt = passportJwt.ExtractJwt
const jwtSecret = process.env.JWT_SECRET ?? '2be8e8b1fce87f544b9a34ccacb7ae334dbf6780c6b6a4e1cb838bcb1fc127c7';

passport.serializeUser<any, any>((req, user, done) => {
    done(undefined, user)
});

passport.deserializeUser((id, done) => {
    userModel.findById(id).exec()
    .then(user => {
      if (!user) return done(new Error('User not found'))
      done(null, user)
    })
    .catch(err => done(err))
})

passport.use(new LocalStrategy({ usernameField: "mobile" }, (mobile, password, done) => {
    userModel.findOne({ mobile: mobile}).exec()
    .then(user => {
        if (!user) return done(undefined, false, { message: `Mobile ${mobile} not found.` })
            user.isValidPassword(password).then((isMatch) => {
            if(isMatch){
                return done(undefined, user)
            }else{
                return done(undefined, false, { message: "Invalid mobile or OTP." })
            }
        });
    })
    .catch(err => done(err))
}))

passport.use(new JwtStrategy(
    {
        jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
        secretOrKey: jwtSecret,
    },
    function (jwtToken, done) {
        userModel.findOne({ _id: jwtToken.id }).exec()
        .then(user => { 
            if (!user) return done(undefined, false)
            done(undefined, user, jwtToken)
        })
        .catch(err => done(err, false))
    }
))

export default passport