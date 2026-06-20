import { Socket } from 'socket.io';
import * as http from "http";
import Jwt from "jsonwebtoken";
import DealService from '@/resources/deal/deal.service';
import IDealMessage from '@/resources/deal/message.interface';
import IChatMessage from '@/resources/chat/message.interface';
import ChatService from '@/resources/chat/chat.service';

class SocketService {
    static io: any;
    static dealService: DealService
    static chatService: ChatService

    constructor(
        server: http.Server
    ){       
        SocketService.dealService = new DealService()
        SocketService.chatService = new ChatService()

        SocketService.io = require('socket.io')(server, {
            connectionStateRecovery: {}
        });
        SocketService.io.use(function(socket:any, next:any){
            if (socket.handshake.query && socket.handshake.query.token){
                Jwt.verify(socket.handshake.query.token, `${process.env.JWT_SECRET}`, function(err: any, decoded: any) {
                    if (err) return next(new Error('Authentication error'));
                    socket.decoded = decoded;
                    console.log(`Socket connected ${decoded.id}`);
                    next();
                });
            }
            else {
                next(new Error('Authentication error'));
            }    
        })

        SocketService.io.on('connection', (socket: Socket) => {
            const self = this
            socket.on('pingCheck', (ack) => {
                ack();  // Respond immediately
            });
            socket.on("dealMessage", async function(newMessage: any) {
                const message = await SocketService.dealService.createDealMessage(newMessage) as IDealMessage
                await SocketService.EmitDealMessage(message)
            }); 
            socket.on("chatMessage", async function(newMessage: any) {
                const message = await SocketService.chatService.createChatMessage(newMessage) as IChatMessage
                await SocketService.EmitChatMessage(message)
            }); 
        });
    }

    public static async EmitDealMessage(message:IDealMessage){
        for (const [id, socket] of SocketService.io.of("/").sockets) {
            const userId = socket.decoded?.id;
            if (!userId) continue; // Skip if user not authenticated
            socket.emit(`deal/${message.deal}`, message.toList())
        }
    }

    public static async EmitChatMessage(message:IChatMessage){
        for (const [id, socket] of SocketService.io.of("/").sockets) {
            const userId = socket.decoded?.id;
            if (!userId) continue; // Skip if user not authenticated
            socket.emit(`chat/${message.chat}`, message.toList())
        }
    }
}
export default SocketService