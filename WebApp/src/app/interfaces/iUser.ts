export interface IUser {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
    displayName: string;
    mobile: string;
    code: string;
    avatar: string;
    isBlocked: boolean;
    isValidate: boolean;
    role: string;
    isDealer: boolean;
    isDealerSubscribed: boolean;
    googleId?:string,
    appleId?:string,
    facebookId?:string
}