
import { Pipe, PipeTransform } from '@angular/core';
import * as moment from 'moment';
@Pipe({
    name: 'moment'
})
export class MomentPipe implements PipeTransform {
    transform(value: Date | moment.Moment, ...args: any[]): any {
        return utcMomentToString(value, ...args);
    }
}

export const utcMomentToString = (value: Date | moment.Moment, ...args: any[]): string => {
    if(!value){
        return '';
    }
    const [format] = args;
    return moment.utc(value).local().format(format);
}
