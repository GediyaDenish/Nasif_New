import chatModel from "@/resources/chat/chat.model"
import messageModel from "@/resources/chat/message.model"
import FileService from "@/utils/services/file.service"
import IUser from "@/resources/user/user.interface"
import IChat from "@/resources/chat/chat.interface"
import { PaginateOptions, PaginateResult } from "mongoose"
import IChatMessage from "@/resources/chat/message.interface"
import fs from 'fs'
import SocketService from "@/utils/services/socket.service"
import userModel from "@/resources/user/user.model"
import PushService from "@/utils/services/push.service"
import moment from "moment"
import IProperty from "../property/property.interface"
import propertyModel from "../property/property.model"

class ChatService {
    private model = chatModel
    private messageModel= messageModel
    private userModel= userModel
    private propertyModel = propertyModel
    private pushService = new PushService()
    private fileService = new FileService()
    private customLabels = { totalDocs: "totalElements", docs: "content", limit: "size", page: "page" }

    public async getChat(
        id: any,
        user: IUser,
    ): Promise<IChat | Error> {
        try {
            let chat = await this.model.findById(id) as IChat 
            if(!chat) { throw new Error('Chat not found')}
            let index = chat.unreadMsg.findIndex(i => i.user.toString() == user.id)
            chat.unreadMsg[index].count = 0;
            chat = await this.model.findByIdAndUpdate(id,{unreadMsg:chat.unreadMsg}, {new: true}).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
            return chat.toJSON(user)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async getChats(
        page:any = 0,
        size:any = 20,
        search:any = '',
        sort: any = {'createdAt':-1},
        user: IUser,
        archived: any
    ): Promise<PaginateResult<IChat> | Error> {
        try {
            const options:PaginateOptions = {
                page: page,
                limit: size,
                sort: sort == '' ? {'createdAt':-1} : sort,
                customLabels: this.customLabels,
                populate: [
                    {
                        path: "lastMessage",
                        model: "ChatMessages",
                        select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]
                    },
                    {
                        path: "member", // This can be an array of ObjectIds
                        model: "User",  // Replace with your actual user model name
                        select: ["avatar", "displayName", "mobile"]
                    }
                ]
            }
            let andCondition = []
            andCondition.push({isDeleted: false})

            if(archived){
                const isArchived = archived === true || archived === 'true';
                if(isArchived){
                    andCondition.push({ archived: { $in: user.id }})
                }else{
                    andCondition.push({ archived: { $nin: user.id }})
                }
            }

            andCondition.push({ $or: [{admin: { $in: user.id } }, {moderator: { $in: user.id }},  {member: { $in: user.id }}] })

            const groupUsers = await this.userModel.find({
                displayName: { $regex: search, $options: "i" }
            }, '_id');
            const userIds = groupUsers.map(u => u._id);
            let query: any = {
            $and: [
                {
                    $or: [
                        {admin: { $in: userIds } },
                        {moderator: { $in: userIds }},
                        {member: { $in: userIds }},
                        {groupName: { $regex: search, $options: "i" }},
                    ]
                },
                ...andCondition
                ]
            };

            let chats: PaginateResult<any> = await this.model.paginate(query,options)
            if(Array.isArray(chats.content)){
                for (let index = 0; index < chats.content.length; index++) {
                    chats.content[index] = chats.content[index].toList(user)
                }
            }
            return chats
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async getChatMessages(
        page: any = 0,
        size: any = 20,
        search: any = '',
        sort: any = {'createdAt':-1},
        user: IUser,
        chat: any
    ): Promise<PaginateResult<IChatMessage> | Error> {
        try {
            const options:PaginateOptions = {
                page: page,
                limit: size,
                sort: sort == '' ? {'createdAt':-1} : sort,
                customLabels: this.customLabels,
                populate: [
                    {
                        path: "sender",
                        model: "User",
                        select: ["_id", "displayName", "avatar", "mobile"]
                    },
                    {
                        path: "property",
                        model: "Properties",
                        select: ["_id", "city", "neighbourhood", "availableFor", "type", "price", "area", "coverImage",'status','area','northFacing','eastFacing','westFacing','southFacing','streets','totalBedrooms','totalBathrooms','totalLivingrooms']
                    }
                ]
            }
            let andCondition = []
            andCondition.push({chat: chat})
            andCondition.push({isDeleted: false})
            
            let query: any = {
            $and: [
                {
                    $or: [
                        // { city: { $regex: search, $options: "i" } },
                    ]
                },
                ...andCondition
                ]
            };

            let chatMessages: PaginateResult<any> = await this.messageModel.paginate(query,options)
            if(Array.isArray(chatMessages.content)){
                for (let index = 0; index < chatMessages.content.length; index++) {
                    chatMessages.content[index] = chatMessages.content[index].toList(user)
                }
            }
            return chatMessages
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async createChat(
        user: IUser,
        groupName?: string,
        groupImage?: string,
        groupDescription?: string,
        admins: string[] = [],
        moderators: string[] = [],
        members: string[] = [],
        contact?: string,
        property?: string
    ): Promise<IChat | Error> {
        try {
            if(groupName != null){
                admins.push(user.id)
            }else{
                members.push(user.id)
            }

            if(groupName == null){
                if(user.blockChatUser?.some(item => members.includes(item))){
                    throw new Error("User is block"); 
                }
            }

            if(contact){
                const registeredUser = await this.userModel.findOne({mobile:{$in: contact}}) as IUser
                if(registeredUser){
                    members.push(registeredUser.id)
                }else{
                    throw new Error('User not registered')
                }
            }

            if (members.length == 2){
                let chat = await this.model.findOne({member:{ $all: members }, isGroup:false}).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
                if(chat != null){
                    if(property){
                        let message = await this.messageModel.create({
                            chat: chat.id,
                            sender: user.id,
                            type: 'Property',
                            property: property,
                        })
                        members.forEach(userId => {
                            if(userId != message.sender.toString()){
                                const existing = chat.unreadMsg.find((msg) => msg.user.toString() == userId);
                                if (existing) {
                                    existing.count += 1;
                                } else {
                                    chat.unreadMsg.push({ user: userId, count: 1 });
                                }
                            }else{
                                const sender = chat.unreadMsg.find((msg) => msg.user.toString() == userId);
                                if (sender) {
                                    sender.count = 0;
                                }
                            }
                        })
                        chat = await this.model.findByIdAndUpdate(chat.id,{lastMessage:message,groupImage:chat.groupImage,unreadMsg:chat.unreadMsg},{new:true}).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
                    }
                    return chat.toJSON(user)
                }
            }

            var chat = await this.model.create({
                admin: admins,
                moderator: moderators,
                member: members,
                isGroup: admins.length > 0,
                groupName:groupName,
                groupDescription: groupDescription
            }) as IChat

            if(groupImage && !groupImage.includes('https://')){
                let base64Data:string = ''
                let mimeType:string = ''
                if(groupImage.includes('data:image/png;base64')){
                    base64Data = groupImage.replace(/^data:image\/png;base64,/, "")
                    mimeType = 'png'
                }else if(groupImage.includes('data:image/jpg;base64')){
                    base64Data = groupImage.replace(/^data:image\/jpg;base64,/, "")
                    mimeType = 'jpg'
                }else if(groupImage.includes('data:image/jpeg;base64')){
                    base64Data = groupImage.replace(/^data:image\/jpeg;base64,/, "")
                    mimeType = 'jpeg'
                }else{
                    base64Data = groupImage
                    mimeType = 'jpg'
                }
                if(base64Data != '' && mimeType != ''){
                    const fileWrite = new Promise((success) => {
                        fs.writeFile(`public/groupImage_${chat.id}.${mimeType}`, base64Data,'base64', (err) => {
                            if (!err) success(`public/groupImage_${chat.id}.${mimeType}`)
                            console.log('Error to file',err)
                        })
                    })
                    const path = await fileWrite as string
                    if(path){
                        chat.groupImage = await this.fileService.uploadFile(path,`chat/${chat.id}/groupImage_${Date.now()}.${mimeType}`,chat.groupImage) as string   
                    }
                }
            }

            const message = chat.isGroup ? await this.messageModel.create({
                chat: chat.id,
                sender: user.id,
                type: 'Title',
                text: `Group created.`
            }) : property ? await this.messageModel.create({
                chat: chat.id,
                sender: user.id,
                type: 'Property',
                property: property,
            }) : await this.messageModel.create({
                chat: chat.id,
                sender: user.id,
                type: 'Title',
                text: `Chat innitiated.`
            })
            
            var allUsers = [...chat.admin,...chat.moderator,...chat.member]
            allUsers= [...new Set(allUsers)]
            allUsers.forEach(userId => {
                const existing = chat.unreadMsg.find((msg) => msg.user.toString() == userId);
                if (existing) {
                    existing.count += 1;
                } else {
                    chat.unreadMsg.push({ user: userId, count: 1 });
                }
            })
            chat = await this.model.findByIdAndUpdate(chat.id,{lastMessage:message,groupImage:chat.groupImage,unreadMsg:chat.unreadMsg},{new:true}).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
            await this.pushService.sendChatPush(user,chat,message)
            return chat.toJSON(user)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async updateChat(
        id:string,
        user: IUser,
        groupName: string,
        groupImage: string,
        groupDescription:string,
        admins: string[] = [],
        moderators: string[] = [],
        members: string[] = [],
    ): Promise<IChat | Error> {
        try {
            var chat = await this.model.findById(id) as IChat
            chat.groupName = groupName == null || groupName == undefined ? chat.groupName : groupName
            chat.groupDescription = groupDescription == null || groupDescription == undefined ? chat.groupDescription : groupDescription
            chat.admin = admins == null || admins == undefined || admins.length == 0 ? chat.admin : admins
            chat.moderator = moderators == null || moderators == undefined || moderators.length == 0 ? chat.moderator : moderators
            chat.member = members == null || members == undefined || members.length == 0 ? chat.member : members
            chat = await this.model.findByIdAndUpdate(chat.id,{groupName:chat.groupName,groupDescription:chat.groupDescription,admin:chat.admin,moderator:chat.moderator,member:chat.member},{new:true}) as IChat

            if(groupImage && !groupImage.includes('https://')){
                let base64Data:string = ''
                let mimeType:string = ''
                if(groupImage.includes('data:image/png;base64')){
                    base64Data = groupImage.replace(/^data:image\/png;base64,/, "")
                    mimeType = 'png'
                }else if(groupImage.includes('data:image/jpg;base64')){
                    base64Data = groupImage.replace(/^data:image\/jpg;base64,/, "")
                    mimeType = 'jpg'
                }else if(groupImage.includes('data:image/jpeg;base64')){
                    base64Data = groupImage.replace(/^data:image\/jpeg;base64,/, "")
                    mimeType = 'jpeg'
                }else{
                    base64Data = groupImage
                    mimeType = 'jpg'
                }
                if(base64Data != '' && mimeType != ''){
                    const fileWrite = new Promise((success) => {
                        fs.writeFile(`public/groupImage_${chat.id}.${mimeType}`, base64Data,'base64', (err) => {
                            if (!err) success(`public/groupImage_${chat.id}.${mimeType}`)
                            console.log('Error to file',err)
                        })
                    })
                    const path = await fileWrite as string
                    if(path){
                        chat.groupImage = await this.fileService.uploadFile(path,`chat/${chat.id}/groupImage_${Date.now()}.${mimeType}`,chat.groupImage) as string   
                    }
                }
            }
            
            var allUsers = [...chat.admin,...chat.moderator,...chat.member]
            allUsers = [...new Set(allUsers)]
            allUsers.forEach(userId => {
                if(userId != user.id.toString()){
                    const existing = chat.unreadMsg.find((msg) => msg.user.toString() == userId);
                    if (existing) {
                        existing.count += 1;
                    } else {
                        chat.unreadMsg.push({ user: userId, count: 1 });
                    }
                }else{
                    const sender = chat.unreadMsg.find((msg) => msg.user.toString() == userId);
                    if (sender) {
                        sender.count = 0;
                    }
                }
            })
            chat = await this.model.findByIdAndUpdate(chat.id,{groupImage:chat.groupImage,unreadMsg:chat.unreadMsg},{new:true}).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
            return chat.toJSON(user)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async joinGroup(
        id:string,
        user: IUser
    ): Promise<IChat | Error> {
        try {
            var chat = await this.model.findById(id) as IChat
            if(chat && chat.isGroup){
                var allUsers = [...chat.admin,...chat.moderator,...chat.member]
                if(allUsers.filter(i => i == user.id).length == 0){
                    let members = chat.member ?? [];
                    members.push(user.id)
                    members = [...new Set(members)];
                    members.forEach(userId => {
                        const existing = chat.unreadMsg.find((msg) => msg.user.toString() == userId);
                        if (existing) {
                            existing.count += 1;
                        } else {
                            chat.unreadMsg.push({ user: userId, count: 1 });
                        }
                    })
                                   
                    const message = await this.messageModel.create({
                        chat: chat.id,
                        sender: user.id,
                        type: 'Title',
                        text: `New member joined.`
                    }) as IChatMessage
                    chat = await this.model.findByIdAndUpdate(chat.id,{member:members,unreadMsg:chat.unreadMsg, lastMessage: message},{new:true}) as IChat
                } 
                chat = await this.model.findById(chat.id).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
                return chat.toJSON(user)
            }
            throw new Error('Chat group not found')
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async createChatMessage(
        message: any
    ): Promise<IChatMessage | Error> {
        try {
            let chat = await this.model.findById(message.chat) as IChat
            let sender = await this.userModel.findById(message?.sender) as IUser
            if(!chat?.isGroup){
                if(sender.blockChatUser?.some(item => chat.member?.includes(item))){
                    throw new Error("User is block"); 
                }
            }
            
            var allUsers = [...chat.admin,...chat.moderator,...chat.member]
            allUsers= [...new Set(allUsers)]
            if(allUsers.some((id:string) => id == message.sender)){
                let chatMessage = await this.messageModel.create({
                    chat: chat.id,
                    sender: message.sender,
                    type: message.type,
                    text: message.text,
                    fileType: message.fileType,
                    fileName: message.fileName,
                    property: message.property
                }) as IChatMessage

                //Shared Property 
                if(message.property){
                    let property = await this.propertyModel.findById(message.property) as IProperty
                    if(property){                        
                        allUsers.forEach(userId => {
                            if(userId != message.sender && property.user != userId){
                                if(!property.sharedWith) {
                                    property.sharedWith = []
                                }
                                property.sharedWith.push(userId)
                            }
                        })
                        property.sharedWith = [...new Set(property.sharedWith)];
                        property = await this.propertyModel.findByIdAndUpdate(property.id,{sharedWith:property.sharedWith},{new: true}).populate({ path: "user", model: "User", select: ['_id','displayName','avatar']}) as IProperty
                    }else{
                        chatMessage.property = undefined
                    }
                }

                if(message.file && message.type  == 'Image'){
                    let fileName = `${chat.id}_${chatMessage.id}_${message.fileName}`
                    chatMessage.file = this.getUrl(message.file,fileName,chat.id)
                    this.uploadFile(message.file,fileName,chat.id)
                }else if(message.file && message.type  == 'Video'){
                    let fileName = `${chat.id}_${chatMessage.id}_${message.fileName}`
                    chatMessage.file = this.getUrl(message.file,fileName,chat.id)
                    this.uploadFile(message.file,fileName,chat.id)
                }else if(message.file && message.type  == 'File' && message.fileType  == 'pdf'){
                    let fileName = `${chat.id}_${chatMessage.id}_${message.fileName}`
                    chatMessage.file = this.getUrl(message.file,fileName,chat.id)
                    this.uploadFile(message.file,fileName,chat.id)
                }
                chatMessage = await this.messageModel.findByIdAndUpdate(chatMessage.id,{file: chatMessage.file},{new: true}).populate({path: "sender", model: "User", select: ["_id", "displayName", "avatar", "mobile"]}) as IChatMessage
                
                allUsers.forEach(userId => {
                    if(userId != message.sender.toString()){
                        const existing = chat.unreadMsg.find((msg) => msg.user.toString() == userId);
                        if (existing) {
                            existing.count += 1;
                        } else {
                            chat.unreadMsg.push({ user: userId, count: 1 });
                        }
                    }else{
                        const sender = chat.unreadMsg.find((msg) => msg.user.toString() == userId);
                        if (sender) {
                            sender.count = 0;
                        }
                    }
                })

                chat = await this.model.findByIdAndUpdate(chat.id,{lastMessage:chatMessage, unreadMsg:chat.unreadMsg},{new:true}) as IChat
                await this.pushService.sendChatPush(sender,chat,message)
                SocketService.EmitChatMessage(chatMessage);
                return chatMessage
            }
            throw new Error("Chat not found");
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async leaveChat(
        user: IUser,
        id: string,
    ): Promise<IChat | Error> {
        try {
            let chat = await this.model.findById(id) as IChat 
            let index = chat.unreadMsg.findIndex(i => i.user == user.id)
            if(index >= 0 && chat.unreadMsg.length > index){chat.unreadMsg[index].count = 0}
            chat.admin = chat.admin.filter(i => i != user.id);
            chat.moderator = chat.moderator.filter(i => i != user.id);
            chat.member = chat.member.filter(i => i != user.id);
            if(chat.admin.length == 0 && chat.moderator.length == 0 && chat.member.length == 0){
                chat.isDeleted = true
            }
            chat = await this.model.findByIdAndUpdate(id,{unreadMsg:chat.unreadMsg, admin:chat.admin, moderator:chat.moderator, member:chat.member, isDeleted: chat.isDeleted}, {new: true}).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
            
            return chat.toJSON(user)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async blockChatUser(
        user: IUser,
        id: string,
    ): Promise<IUser | Error> {
        try {
            let userForBlock = await this.userModel.findById(id) as IUser
            if(userForBlock == undefined || userForBlock == null || userForBlock.id == user.id){
                throw new Error("User not found")
            } 
            if(user.blockChatUser == undefined || user.blockChatUser == null){
                user.blockChatUser = []
            }
            user.blockChatUser.push(id)
            user.blockChatUser = [...new Set(user.blockChatUser)]
            let response = await this.userModel.findByIdAndUpdate(user.id,{blockChatUser:user.blockChatUser}) as IUser
            return response != null ? response : new Error('Error to block user')
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async unBlockChatUser(
        user: IUser,
        id: string,
    ): Promise<IUser | Error> {
        try {
            user.blockChatUser = user.blockChatUser?.filter(i => i != id);
            let response = await this.userModel.findByIdAndUpdate(user.id,{blockChatUser:user.blockChatUser}) as IUser
            return response != null ? response : new Error('Error to unblock user')
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async removeFromChat(
        user: IUser,
        id: string,
        userId: string
    ): Promise<IChat | Error> {
        try {
            let chat = await this.model.findById(id) as IChat 
            if(!chat.admin.includes(user.id)){
                throw new Error("You don't have permission to remove from group")
            }else if(chat.isDeleted || !chat.isGroup){
                throw new Error("Group not found")
            }

            let index = chat.unreadMsg.findIndex(i => i.user == user.id)
            if(index >= 0 && chat.unreadMsg.length > index){chat.unreadMsg[index].count = 0}
            chat.admin = chat.admin.filter(i => i != userId);
            chat.moderator = chat.moderator.filter(i => i != userId);
            chat.member = chat.member.filter(i => i != userId);
            if(chat.admin.length == 0 && chat.moderator.length == 0 && chat.member.length == 0){
                chat.isDeleted = true
            }
            chat = await this.model.findByIdAndUpdate(id,{unreadMsg:chat.unreadMsg, admin:chat.admin, moderator:chat.moderator, member:chat.member, isDeleted: chat.isDeleted}, {new: true}).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
            return chat.toJSON(user)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async changeGroupMember(
        user: IUser,
        id: string,
        currentType: string,
        userId: string,
        newType: string
    ): Promise<IChat | Error> {
        try {
            let chat = await this.model.findById(id) as IChat 
            if(!chat.admin.includes(user.id)){
                throw new Error("You don't have permission to change in group")
            }else if(chat.isDeleted || !chat.isGroup){
                throw new Error("Group not found")
            }

            if(currentType == 'admin'){
                chat.admin = chat.admin.filter(i => i != userId);
            }else if(currentType == 'moderator'){
                chat.moderator = chat.moderator.filter(i => i != userId);
            }else if(currentType == 'member'){
                chat.member = chat.member.filter(i => i != userId);
            }

            if(newType == 'admin'){
                chat.admin.push(userId)
            }else if(newType == 'moderator'){
                chat.moderator.push(userId)
            }else if(newType == 'member'){
                chat.member.push(userId)
            }

            chat.admin = [...new Set(chat.admin)];
            chat.moderator = [...new Set(chat.moderator)];
            chat.member = [...new Set(chat.member)];

            if(chat.admin.length == 0 && chat.moderator.length == 0 && chat.member.length == 0){
                chat.isDeleted = true
            }
            chat = await this.model.findByIdAndUpdate(id,{unreadMsg:chat.unreadMsg, admin:chat.admin, moderator:chat.moderator, member:chat.member, isDeleted: chat.isDeleted}, {new: true}).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
            return chat.toJSON(user)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }

    public async deleteChat(
        user: IUser,
        id: string,
    ): Promise<IChat | Error> {
        try {
            let chat = await this.model.findById(id) as IChat 
            if(chat.isGroup && !chat.admin.includes(user.id)){
                throw new Error("You don't have permission to delete group")
            }
            var allUsers = [...chat.admin,...chat.moderator,...chat.member]
            allUsers= [...new Set(allUsers)]
            allUsers.forEach(userId => {
                const existing = chat.unreadMsg.find((msg) => msg.user.toString() == userId);
                if (existing) {
                    existing.count = 0;
                } else {
                    chat.unreadMsg.push({ user: userId, count: 0 });
                }
            })
            chat = await this.model.findByIdAndUpdate(id,{unreadMsg:chat.unreadMsg,isDeleted: true}, {new: true}).populate('admin', 'avatar displayName mobile').populate('moderator', 'avatar displayName mobile').populate('member', 'avatar displayName mobile').populate({ path: "lastMessage", model: "ChatMessages", select: ["_id", "sender", "type", "text", "file", "fileType", "createdAt"]}) as IChat
            return chat.toJSON(user)
        }catch (error: any) {
            throw new Error(error.message)
        }
    }
    
    private getUrl(file:string,name:string,id:string){
        if(file.includes('data:image/png;base64')){
            return `https://${ process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/chat/${id}/messages/${name}`
        }else if(file.includes('data:image/jpeg;base64')){
            return `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/chat/${id}/messages/${name}`
        }else if(file.includes('data:application/pdf;base64')){
            return `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/chat/${id}/messages/${name}`
        }else{
            return `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/chat/${id}/messages/${name}`
        }
    }

    private async uploadFile(file:string,name:string,id:string){
        let base64Data:string = ''
        let mimeType:string = ''
        if(file.includes('data:image/png;base64')){
            base64Data = file.replace(/^data:image\/png;base64,/, "")
            mimeType = 'png'
        }else if(file.includes('data:image/jpg;base64')){
            base64Data = file.replace(/^data:image\/jpg;base64,/, "")
            mimeType = 'jpg'
        }else if(file.includes('data:image/jpeg;base64')){
            base64Data = file.replace(/^data:image\/jpeg;base64,/, "")
            mimeType = 'jpeg'
        }else if(file.includes('data:application/pdf;base64')){
            base64Data = file.replace(/^data:application\/pdf;base64,/, "")
            mimeType = 'pdf'
        }else if(file.includes('data:video/')){
            base64Data = file.replace(/^data:video\/\w+;base64,/, "")
            mimeType = 'video'
        }else{
            base64Data = file
            mimeType = 'jpg'
        }
        if(base64Data != '' && mimeType != ''){
            let imageName = `chats_${id}_${name}`
            const fileWrite = new Promise((success) => {
                fs.writeFile(`public/${imageName}`, base64Data,'base64', (err) => {
                    if (!err) success(`public/${imageName}`)
                })
            })
            const path = await fileWrite as string
            if(path){
                return await this.fileService.uploadFile(path,`chat/${id}/messages/${name}`) as string   
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
                    messages : await this.model.countDocuments({createdAt:{$gte: moment(now).subtract(index, 'days').startOf('day').toDate(), $lt: moment(now).subtract(index, 'days').endOf('day').toDate()}}),
                    time : moment(now).subtract(index,'days').toISOString()
                }
                chart.push(summary)
            }
            
            now = new Date()
            let summary = {
                chart: chart,
                totalMessages: await this.model.countDocuments({createdAt:{$gte: moment(now).subtract(days, 'days').startOf('day').toDate()}})
            }
            return summary
        }catch (error: any) {
            throw new Error(error.message)
        }  
    }    
}
export default ChatService