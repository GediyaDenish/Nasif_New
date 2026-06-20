
import path from 'path'
import fs from 'fs'
import IChatMessage from '@/resources/chat/message.interface';
import IUser from '@/resources/user/user.interface';
import admin from '@/utils/firebase';
import IChat from '@/resources/chat/chat.interface';

class PushService {
    public async sendChatPush(user:IUser,chat: IChat,message:IChatMessage){
        var allUsers = [...chat.admin,...chat.moderator,...chat.member]
        allUsers= [...new Set(allUsers)]
        allUsers.forEach(async (userId:string) => {
            if(userId != user.id){
                const pushData = {
                    body: message.type == 'Property' ? 'تمت مشاركة العقار' : message.type == 'Image' ? 'تمت مشاركة الصورة' : message.type == 'File' ? 'تمت مشاركة الملف' : message.type == 'Video' ? 'تمت مشاركة الفيديو' : message.text,
                    title: chat?.isGroup ? chat.groupName : user.displayName
                }
                const pushBody = {
                    topic: `${userId?.toString().replace(/[^a-zA-Z0-9_\-\.]/g, "")}`,
                    notification: pushData,
                    android: {
                        notification: pushData
                    },
                    webpush: {
                        headers: {
                            chat: message.chat.toString()
                        },
                        data: {
                            chat: message.chat.toString()
                        },
                        notification: pushData
                    },
                    apns: {
                        headers: {
                            chat: message.chat.toString()
                        },
                        payload: {
                            aps: {
                                alert: {
                                    title: pushData.title,
                                    body: pushData.body
                                },
                                sound: 'default', // 👈 This is required to play sound on iOS
                            }
                        }                    
                    },
                    data: {
                        chat: message.chat.toString()
                    }
                }

                try {
                    let response = await admin.messaging().send(pushBody)
                    console.log(response)
                } catch (error) {
                    console.error('Error sending message:', error)
                }
            }
        })
    }
}
export default PushService