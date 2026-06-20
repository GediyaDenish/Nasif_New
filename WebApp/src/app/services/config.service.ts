import { HttpClient, HttpParams } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";
import { IConfig } from "../interfaces/IConfig";
import { IMessage } from "../interfaces/IMessage";
import { IPage } from "../interfaces/IPage";
import { IPageable } from "../interfaces/IPageable";
import { Logger } from "./logger.service";

const log = new Logger('ConfigService');

@Injectable({
    providedIn: 'root'
})
export class ConfigService {

    constructor(
        private _http: HttpClient,
    ){}
    
    getPolicy():Observable<IConfig> {
        return this._http.get<IConfig>(`${environment.baseUrl}/commons/policy/`,{})
    }

    updatePolicy(data:string):Observable<IConfig> {
        return this._http.put<IConfig>(`${environment.baseUrl}/commons/policy/`,{ policy:data })
    }

    getTerms():Observable<IConfig> {
        return this._http.get<IConfig>(`${environment.baseUrl}/commons/terms/`,{})
    }

    updateTerms(data:string):Observable<IConfig> {
        return this._http.put<IConfig>(`${environment.baseUrl}/commons/terms/`,{ terms:data })
    }
}