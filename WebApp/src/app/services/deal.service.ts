import { Injectable } from "@angular/core";
import { Logger } from "./logger.service";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";

const log = new Logger('DealService');

@Injectable({
    providedIn: 'root'
})
export class DealService {

    constructor(
        private _http: HttpClient,
    ){}

    getCounts(days:number):Observable<any>{
        return this._http.get<any>(`${environment.baseUrl}/deals/${days}/count/`,{});
    }
    getSummary(days:number):Observable<any>{
        return this._http.get<any>(`${environment.baseUrl}/deals/${days}/summary/`,{});
    }
}