export interface IPage<T> {
    content: T[];
    first: boolean;
    last: boolean;
    empty: boolean;
    totalElements: number;
    totalPages: number;
    number: number;
    numberOfElements: number;
    size: number;
}