import * as moment from "moment";
import { ICar } from "./ICar";
import { IUser } from './IUser';
export interface ISupport {
    _id: string;
    closed: boolean;
    userDetail: IUser;
    unreadCount:number;
    carDetail?: ICar;
    messages?:any[];
    lastUpdate:string;
}