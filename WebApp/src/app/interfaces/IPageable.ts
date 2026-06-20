export interface IPageable {
    page: number;
    size: number;
    sort?: string;
    search?: string;
    user?: string;
    car?: string;
}