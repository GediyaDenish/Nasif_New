import { HttpErrorResponse, HttpEvent, HttpHandler, HttpInterceptor, HttpRequest, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { ToastrService } from 'ngx-toastr';
import { Observable } from 'rxjs';
import { filter, map, take, tap } from 'rxjs/operators';
import { IMessage } from '../interfaces/IMessage';
import { Logger } from './logger.service';

const log = new Logger('MessageInterceptor');

@Injectable()
export class MessageInterceptor implements HttpInterceptor {
    constructor(
        private _toastr: ToastrService
    ) { }

    public intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
        return next.handle(request).pipe( 
            tap(
                (event:any) => {
                    if(event instanceof HttpResponse && event.body['message']){
                        this.showMessage(event.body)
                    }
                },
                (error: any) => {
                    if(error instanceof HttpErrorResponse && error.error['message']){
                        this.showMessage(error.error)
                    }
                }
            )
        )
    }
    private showMessage(message: IMessage) {
        if(message.status){
            this._toastr.success(message.message);
        }else{
            this._toastr.error(message.message);
        }
    }
}
