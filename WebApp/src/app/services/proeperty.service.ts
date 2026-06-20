import { Injectable } from "@angular/core";
import { Logger } from "./logger.service";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";

const log = new Logger('PropertyService');

@Injectable({
    providedIn: 'root'
})
export class PropertyService {

    constructor(
        private _http: HttpClient,
    ){}

    getCounts(days:number):Observable<any>{
        return this._http.get<any>(`${environment.baseUrl}/properties/${days}/count/`,{});
    }
    getSummary(days:number):Observable<any>{
        return this._http.get<any>(`${environment.baseUrl}/properties/${days}/summary/`,{});
    }
}