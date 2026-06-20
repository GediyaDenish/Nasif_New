import { Component, forwardRef, Input, OnChanges, OnDestroy, OnInit, SimpleChanges } from '@angular/core';
import { ControlValueAccessor, FormControl, NG_VALUE_ACCESSOR } from '@angular/forms';
import { ReplaySubject, Subject } from 'rxjs';
import { debounceTime, distinctUntilChanged, takeUntil } from 'rxjs/operators';
import { IPageable } from 'src/app/interfaces/IPageable';
import { IUser } from 'src/app/interfaces/IUser';
import { UserService } from 'src/app/services/user.service';

@Component({
  selector: 'select-user',
  templateUrl: './select-user.component.html',
  styleUrls: ['./select-user.component.scss'],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      multi: true,
      useExisting: forwardRef(() => SelectUserComponent)
    }
  ]
})
export class SelectUserComponent implements OnInit, OnDestroy, ControlValueAccessor, OnChanges {

  private _unsubscribeAll: Subject<any> = new Subject<any>();

  @Input() disabled = false;
  @Input() label = '';

  _value?: IUser;
  filter: FormControl = new FormControl();
  filteredElements: ReplaySubject<IUser[]> = new ReplaySubject<IUser[]>(1);
  elements: IUser[] = [];
  paginator: IPageable;

  onChange: Function = (_: any) => { };
  onTouched: Function = (_: any) => { };

  constructor(
    private _userService: UserService
  ) {
    this.paginator = {
      page: 0,
      size: 25,
      sort: 'firstName'
    }
  }
  ngOnChanges(changes: SimpleChanges): void {

    this.init(this.filter.value);
    
  }

  ngOnInit() {
    this.filter.valueChanges
      .pipe(
        distinctUntilChanged(),
        debounceTime(250),        
        takeUntil(this._unsubscribeAll)
      )
      .subscribe(() => this.init(this.filter.value));
  }




  set value(val: IUser | undefined) {
    this._value = val;
    this.onChange(val);
    this.onTouched(val);
  }

  writeValue(value: IUser) {
    this.value = value;
    this.init(this.filter.value);
  }

  registerOnChange(fn: Function) {
    this.onChange = fn;
  }

  registerOnTouched(fn: Function) {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }

  init(filter: string = "") {
    if (filter) {
      this.paginator.search = filter
    }
    
    this._userService.getUsers(this.paginator,true).subscribe(usersPage => {
      this.elements = usersPage.content;
      this.filteredElements.next(this.elements.slice());

      if (this.value) {
        this.value = this.elements.find(x => x.id === this.value?.id);
      }
    });
  }

  ngOnDestroy(): void {
    this._unsubscribeAll.next();
    this._unsubscribeAll.complete();
  }

  get value(): IUser | undefined {
    return this._value;
 }

}
