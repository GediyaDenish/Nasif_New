import { config } from 'dotenv'
import 'module-alias/register'
import path from 'path'
import validateEnv from '@/utils/validateEnv';
import App from './app';
import AuthController from '@/resources/auth/auth.controller';
import UserController from '@/resources/user/user.controller';
import FaqController from '@/resources/faq/faq.controller';
import PropertyController from '@/resources/property/property.controller';
import CommonController from '@/resources/common/common.controller';
import DealController from '@/resources/deal/deal.controller';
import ChatController from '@/resources/chat/chat.controller';

config({
    path: path.resolve(`${__dirname}/env`, `.env.${process.env.NODE_ENV}`)
});

validateEnv()

const app = new App(
    [
        new AuthController(),
        new UserController(),
        new FaqController(),
        new PropertyController(),
        new CommonController(),
        new DealController(),
        new ChatController()
    ],
    Number(process.env.PORT)
);

app.listen()