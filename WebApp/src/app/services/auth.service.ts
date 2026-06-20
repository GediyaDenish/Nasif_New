import { Injectable } from "@angular/core";
import { BehaviorSubject, Observable } from "rxjs";
import { Logger } from "./logger.service";
import { tap } from 'rxjs/operators';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from "src/environments/environment";
import { Params, Router } from "@angular/router";
import jwt_decode from 'jwt-decode';
import { IUser } from "../interfaces/IUser";

const log = new Logger('AuthService');

@Injectable({
    providedIn: 'root'
})
export class AuthService {

    private _user?:IUser;
    private _sideBarOpen:boolean = true;
    public user: BehaviorSubject<IUser | undefined> = new BehaviorSubject<IUser | undefined>(this._user);
    public sideBarOpen: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(this._sideBarOpen);
    
    constructor(
        private _router: Router,
        private _http: HttpClient,
    ){}

    isAuthenticated(): boolean {
        const tokenInfo = this.getDecodedAccessToken(sessionStorage.getItem("accessToken"))
        if(tokenInfo && tokenInfo.authority.includes('user')){
            return true;
        }
        return false;
    }

    login(code: string, mobile: string, otp:string, redirectPath: string): Observable<any> {
        return this._http.post<any>(`${environment.baseUrl}/auth/verify`, {
            code: mobile.length == 9 ? '966' : code,
            mobile: mobile,
            otp: otp
        }).pipe(tap(response => this.setToken(response,redirectPath)))
    }
    
    resendOtp(code: string, mobile: string): Observable<any> {
        return this._http.post<any>(`${environment.baseUrl}/auth/signin`, {
            code: mobile.length == 9 ? '966' : code,
            mobile: mobile
        })
    }

    setToken(params: Params, redirect?: string, loadUser:boolean = true){
        sessionStorage.setItem("userId",params.userId)
        sessionStorage.setItem("accessToken",params.accessToken)
        sessionStorage.setItem("type",params.type)
        sessionStorage.setItem("email",params.email)
        sessionStorage.setItem("topic",params.topic)
        if(loadUser){
            this.loadUser(redirect)
        }
    }

    logout() {
        localStorage.clear();
        sessionStorage.clear();
        this.user.next(undefined);
        this._router.navigateByUrl('/auth');
        window.location.reload();
    }

    loadUser(redirect?: string) {
        return this._http.get<IUser>(`${environment.baseUrl}/users/me/`, {}).pipe(tap(response => {
            if(!response.role || !response.role?.includes('admin')){
                this.logout();
            }
            this.user.next(response)
            if (redirect) {
                const url = this._router.parseUrl(redirect);
                this._router.navigateByUrl(url);
            }
        }))
    }

    private getDecodedAccessToken(token: string | null): any {
        if(!token){ return null; }
        try {
          return jwt_decode(token);
        } catch(Error) {
          return null;
        }
    }
}