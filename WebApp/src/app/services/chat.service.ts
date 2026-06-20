import { Injectable } from "@angular/core";
import { Logger } from "./logger.service";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";

const log = new Logger('ChatService');

@Injectable({
    providedIn: 'root'
})
export class ChatService {

    constructor(
        private _http: HttpClient,
    ){}

    getMessagesCount(days:number):Observable<any>{
        return this._http.get<any>(`${environment.baseUrl}/chats/${days}/count/messages`,{});
    }

    getSummary(days:number):Observable<any>{
        return this._http.get<any>(`${environment.baseUrl}/chats/${days}/summary/`,{});
    }
}