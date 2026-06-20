import { Injectable } from "@angular/core";
import { BehaviorSubject } from "rxjs";
import { io, Socket } from "socket.io-client";
import { environment } from "src/environments/environment";

@Injectable({
    providedIn: 'root'
})
export class SocketService {
    
    private _socket?:Socket;
    public socket: BehaviorSubject<Socket | undefined> = new BehaviorSubject<Socket | undefined>(this._socket);
    constructor(){}

    init(){
        const token = sessionStorage.getItem("accessToken");
        this._socket = io(`${environment.socketUrl}?token=${token}`,{transports: ["websocket"]});
        this.socket.next(this._socket);
    }
}