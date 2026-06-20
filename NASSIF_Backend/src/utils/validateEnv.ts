import { string } from '@hapi/joi';
import { cleanEnv, str, port, num } from 'envalid';

function validateEnv(): void {
    cleanEnv(process.env, {
        NODE_ENV: str({
            choices: ['dev', 'staging', 'prod']
        }),
        PORT: port(),
        URL_PREFIX : str(),
        VERSION: num(),
        MONGO_PASSWORD: str(),
        MONGO_PATH: str(),
        MONGO_USER: str(),
        JWT_SECRET: str(),
        AUTH_CALLBACK_URL: str(),
        TWILIO_ACCOUNT_SID: str(),
        TWILIO_AUTH_TOKEN: str(),
        AWS_ACCESS_KEY_ID: str(),
        AWS_SECRET_ACCESS_KEY: str(),
        AWS_S3_BUCKET_NAME: str()
    });
}

export default validateEnv;
