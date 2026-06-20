export default interface IDealMessage {
    id: string,
    deal: string,
    buyer: string,
    type: string,
    text: string,
    file: string,
    fileType: string,
    fileName: string,
    toList(): Promise<IDealMessage>
    toJSON(): Promise<IDealMessage>
}