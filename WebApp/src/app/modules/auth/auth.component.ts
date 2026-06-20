import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { Logger } from 'src/app/services/logger.service';

const log = new Logger('Auth');

@Component({
  selector: 'app-auth',
  templateUrl: './auth.component.html',
  styleUrls: ['./auth.component.scss']
})
export class AuthComponent implements OnInit, OnDestroy {
  
  private _unsubscribe: Subject<any> = new Subject();

  authView:string = "sign-in-email";

  constructor(
    private _activatedRoute: ActivatedRoute
  ) { }

  ngOnInit(): void {
    this._activatedRoute.params
      .pipe(takeUntil(this._unsubscribe))
      .subscribe((params: Params) => {
        this.authView = params.view == undefined ? this.authView : params.view;
      });
  }

  ngOnDestroy(): void {
    this._unsubscribe.next();
    this._unsubscribe.complete();
  }
}
