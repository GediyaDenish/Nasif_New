export default interface IDeal {
    id: string,
    dealNo:number,
    name:string,
    user: string,
    buyer: string,
    isDeleted: boolean,
    lastMessage: string,
    status: string,
    subStatus: number,
    userUnreadMsg: number,
    buyerUnreadMsg: number,
    archivedBy?:string[],
    toList(userId:string): Promise<IDeal>
    toJSON(userId:string): Promise<IDeal>
}