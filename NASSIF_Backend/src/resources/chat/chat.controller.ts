import passportMiddleware from "@/middleware/passportMiddleware"
import validationMiddleware from "@/middleware/validationMiddleware"
import HttpException from "@/utils/exceptions/httpException"
import Controller from "@/utils/interfaces/controller.interface"
import { NextFunction, Request, Response, Router } from "express"
import IUser from "@/resources/user/user.interface"
import Validate from "@/resources/chat/chat.validation"
import IChat from "@/resources/chat/chat.interface"
import ChatService from "@/resources/chat/chat.service"
import IChatMessage from "./message.interface"

class ChatController implements Controller {
    public path = '/chats'
    public router = Router()
    private service = new ChatService()

    constructor() {
        this.initialiseRoutes()
    }

    private initialiseRoutes(): void {
        this.router.get(
            `${this.path}/`,
            passportMiddleware('jwt'),
            this.getChats
        ),
        this.router.get(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            this.getChat
        ),
        this.router.put(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.updateGroup),
            this.updateChat
        ),
        this.router.put(
            `${this.path}/:id/join/`,
            passportMiddleware('jwt'),
            this.joinChatGroup
        ),
        this.router.get(
            `${this.path}/:id/messages/`,
            passportMiddleware('jwt'),
            this.getChatMessages
        ),
        this.router.post(
            `${this.path}/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.createGroup),
            this.createChat
        ),
        this.router.post(
            `${this.path}/:id/message/`,
            passportMiddleware('jwt'),
            validationMiddleware(Validate.createMessage),
            this.createChatMessage
        ),
        this.router.delete(
            `${this.path}/:id/leave/`,
            passportMiddleware('jwt'),
            this.leaveChat
        ),
        this.router.delete(
            `${this.path}/:id/block/`,
            passportMiddleware('jwt'),
            this.blockChatUser
        ),
        this.router.delete(
            `${this.path}/:id/unblock/`,
            passportMiddleware('jwt'),
            this.unBlockChatUser
        ),
        this.router.delete(
            `${this.path}/:id/`,
            passportMiddleware('jwt'),
            this.deleteChat
        ),
        this.router.delete(
            `${this.path}/:id/remove/:userId/`,
            passportMiddleware('jwt'),
            this.removeFromChat
        ),
        this.router.put(
            `${this.path}/:id/change/:currentType/:userId/:newType/`,
            passportMiddleware('jwt'),
            this.changeGroupMember
        ),
        this.router.get(
            `${this.path}/:days/count/messages`,
            passportMiddleware('jwt'),
            this.getDayCounts
        ),
        this.router.get(
            `${this.path}/:days/summary/`,
            passportMiddleware('jwt'),
            this.getDaysSummary
        )
    }

    private getChats = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { page, size, search, sort, archived} = req.query
            const chats = await this.service.getChats( page, size, search, sort, user, archived)
            res.status(200).json(chats)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

     private getChat = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const chat = await this.service.getChat(id,user)
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getChatMessages = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { id } = req.params
            const user = req.user as IUser
            const {page, size, search, sort} = req.query
            const chatMessages = await this.service.getChatMessages(page, size, search, sort, user, id)
            res.status(200).json(chatMessages)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private createChat = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { groupName, groupImage, groupDescription, admins, moderators, members, contact} = req.body
            const chat = await this.service.createChat(user, groupName, groupImage, groupDescription, admins, moderators, members, contact) as IChat
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private updateChat = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id } = req.params
            const { groupName, groupImage, groupDescription, admins, moderators, members} = req.body
            const chat = await this.service.updateChat(id, user, groupName, groupImage, groupDescription, admins, moderators, members) as IChat
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private joinChatGroup = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id } = req.params
            const chat = await this.service.joinGroup(id, user) as IChat
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private createChatMessage = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id } = req.params
            const message = {
                chat: id,
                sender: user.id,
                type: req.body.type,
                file: req.body.file,
                fileType: req.body.fileType,
                fileName: req.body.fileName
            }
            const chatMessage = await this.service.createChatMessage(message) as IChatMessage
            res.status(200).json(chatMessage)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }
    private leaveChat = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id } = req.params
            const chat = await this.service.leaveChat(user, id) as IChat
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private blockChatUser = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id } = req.params
            const chat = await this.service.blockChatUser(user, id) as IUser
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private unBlockChatUser = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id } = req.params
            const chat = await this.service.unBlockChatUser(user, id) as IUser
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private deleteChat = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id } = req.params
            const chat = await this.service.deleteChat(user, id) as IChat
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private removeFromChat = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id, userId } = req.params
            const chat = await this.service.removeFromChat(user, id, userId) as IChat
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private changeGroupMember = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const user = req.user as IUser
            const { id, currentType, userId, newType} = req.params
            const chat = await this.service.changeGroupMember(user, id, currentType, userId, newType) as IChat
            res.status(200).json(chat)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getDayCounts = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { days } = req.params
            const counts = await this.service.getCounts(+days)
            res.status(200).json(counts)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }

    private getDaysSummary = async (req: Request, res: Response, next: NextFunction ): Promise<Response | void> => {
        try {
            const { days } = req.params
            const summary = await this.service.getDaysSummary(+days)
            res.status(200).json(summary)
        } catch (error: any) {
            next(new HttpException(400, error.message))
        }
    }
}
export default ChatController