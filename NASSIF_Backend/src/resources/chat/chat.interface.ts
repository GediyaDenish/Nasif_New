import IUser from "../user/user.interface"

export default interface IChat {
    id: string,
    lastMessage?: string,
    groupName?: string,
    groupImage?: string,
    groupDescription?: string,
    isDeleted: boolean,
    isGroup: boolean,
    isArchived: boolean,
    isAdmin: boolean,
    isModerator: boolean,
    isMember: boolean,
    unreadMsg: [{
        user:string,
        count:number
    }],
    admin:string[],
    moderator:string[],
    member:string[],
    toList(user:IUser): Promise<IChat>
    toJSON(user:IUser): Promise<IChat>
}