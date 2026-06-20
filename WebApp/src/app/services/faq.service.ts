import { HttpClient, HttpParams } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";
import { IFaq } from "../interfaces/IFaq";
import { IMessage } from "../interfaces/IMessage";
import { IPage } from "../interfaces/IPage";
import { IPageable } from "../interfaces/IPageable";

@Injectable({
    providedIn: 'root'
})
export class FaqService {

    constructor(
        private _http: HttpClient,
    ){}

    getFaqs(page:IPageable): Observable<IPage<IFaq>> {
        let filters = new HttpParams();
        filters = filters.set('page', page.page.toString());
        filters = filters.set('size', page.size ?? 20);
        filters = filters.set('sort', page.sort ?? "createdAt");
        filters = filters.set('search', page.search ?? "");
        return this._http.get<IPage<IFaq>>(`${environment.baseUrl}/faqs/`,{ params: filters });
    }

    updateFaq(id:string,que:string,ans:string): Observable<IMessage> {
        return this._http.put<IMessage>(`${environment.baseUrl}/faqs/${id}`,{ que: que, ans:ans })
    }

    createFaq(que:string,ans:string): Observable<IMessage> {
        return this._http.post<IMessage>(`${environment.baseUrl}/faqs/`,{ que: que, ans:ans })
    }

    deleteFaq(id:string): Observable<IMessage> {
        return this._http.delete<IMessage>(`${environment.baseUrl}/faqs/${id}`,{})
    }

}