import { HttpClient, HttpParams } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";
import { IPageable } from "../interfaces/IPageable";
import { Logger } from "./logger.service";

const log = new Logger('UserService');

@Injectable({
    providedIn: 'root'
})
export class UserService {

    constructor(
        private _http: HttpClient,
    ){}

    getUsers(page:IPageable,withName:boolean = false): Observable<any> {
        let filters = new HttpParams();
        filters = filters.set('page', page.page.toString());
        filters = filters.set('size', page.size ?? 20);
        filters = filters.set('sort', page.sort ?? "displayName");
        filters = filters.set('search', page.search ?? "");
        return this._http.get<any>(`${environment.baseUrl}/users/?withName=${withName}`,{ params: filters })
    }

    updateUser(id:string,isBlocked?:boolean,isAdmin?:boolean){
        return this._http.put<any>(`${environment.baseUrl}/users/${id}/`,{ isBlocked:isBlocked,isAdmin:isAdmin })
    }

    changePassword(password?:string,confirmPassword?:string){
        return this._http.post<any>(`${environment.baseUrl}/users/changePassword/`,{ password:password,confirmPassword:confirmPassword })
    }

    editProfile(displayName:string,mobile:string){
        return this._http.put<any>(`${environment.baseUrl}/users/me`,{ displayName:displayName,mobile:mobile })
    }

    getCounts(days:number):Observable<any>{
        return this._http.get<any>(`${environment.baseUrl}/users/${days}/count/`,{});
    }
    getSummary(days:number):Observable<any>{
        return this._http.get<any>(`${environment.baseUrl}/users/${days}/summary/`,{});
    }
}