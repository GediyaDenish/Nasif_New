export default interface IChatMessage {
    id: string,
    chat: string,
    sender: string,
    type: string,
    text: string,
    file: string,
    fileType: string,
    fileName: string,
    property?: string,
    toList(): Promise<IChatMessage>
    toJSON(): Promise<IChatMessage>
}