import { S3Client, PutObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";
import fs from 'fs'

class FileService {

    private s3 = new S3Client({ region: process.env.AWS_REGION });
    private baseS3Url = `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com`

    constructor(){
        this.s3 = new S3Client({
            region: process.env.AWS_REGION,
            credentials: {
                accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
                secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
            },
        });
    }

    private deleteFile(path:string,url?:string){
        fs.unlinkSync(path)
        if(url){
            const command = new DeleteObjectCommand({
                Bucket: process.env.AWS_S3_BUCKET_NAME,
                Key: url.replace(new RegExp(`^${this.baseS3Url}/?`), "")
            });
            this.s3.send(command).then(data => {
                console.log("Successfully deleted object:", data);
            }).catch(error =>{
                console.error("Failed to delete object:", error);
            })
        }
    }
    
    public deleteS3File(url?:string){
        if(url){
            const command = new DeleteObjectCommand({
                Bucket: process.env.AWS_S3_BUCKET_NAME,
                Key: url.replace(new RegExp(`^${this.baseS3Url}/?`), ""),
            });
            this.s3.send(command).then(data => {
                console.log("Successfully deleted object:", data);
            }).catch(error =>{
                console.error("Failed to delete object:", error);
            })
        }
    }

    public async uploadFile(path:string,url:string,oldUrl?:string): Promise<string | undefined> {        
        const command = new PutObjectCommand({
            Bucket: process.env.AWS_S3_BUCKET_NAME,
            Body : fs.createReadStream(path),
            Key : url
        })
        return this.s3.send(command).then((data) => {
            this.deleteFile(path,oldUrl)
            console.log("Successfully deleted object:", data);
            return `${this.baseS3Url}/${url}`
        }).catch(error => {
            console.error("Failed to delete object:", error);
            return undefined
        })
    }
}
export default FileService