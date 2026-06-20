import { HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";

@Injectable()
export class TokenInterceptor implements HttpInterceptor {

    public intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
        req = this.applyCredentials(req)
        return next.handle(req)
    }

    private applyCredentials(req: HttpRequest<any>): HttpRequest<any> {
        const token = sessionStorage.getItem("accessToken");
        if (token) {
            const authorizationHeader = `Bearer ${token}`;
            req = req.clone({ setHeaders: { Authorization: authorizationHeader } });
        }
        return req;
    }
    
}