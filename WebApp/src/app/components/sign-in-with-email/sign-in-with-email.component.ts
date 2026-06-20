import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute, Params, Router } from '@angular/router';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { AuthService } from 'src/app/services/auth.service';
import { Logger } from 'src/app/services/logger.service';

const log = new Logger('SignInWithEmail');

@Component({
  selector: 'app-sign-in-with-email',
  templateUrl: './sign-in-with-email.component.html',
  styleUrls: ['./sign-in-with-email.component.scss']
})
export class SignInWithEmailComponent implements OnInit, OnDestroy {
  
  private _unsubscribe: Subject<any> = new Subject();
  private queryParams?:Params;
  private code:string = '91';
  private mobile:string = '';
  private otp:string = '';

  isOtpSent:boolean = false;
  isValid:boolean = false;

  constructor(
    private _router: Router,
    private _activatedRoute: ActivatedRoute,
    private _authService: AuthService
  ) { }

  ngOnInit(): void {
    this._activatedRoute.queryParams
    .pipe(takeUntil(this._unsubscribe))
    .subscribe(params => {
      this.queryParams = params;
    });
  }

  ngOnDestroy(): void {
    this._unsubscribe.next();
    this._unsubscribe.complete();
  }
  
  changeView(view:string){
    this._router.navigate([`/auth/${view}`], { queryParams: this.queryParams, replaceUrl: true });
  }

  signIn(){
    if(this.isValid){
      this._authService.login(this.code,this.mobile,this.otp,this.queryParams?.redirect).subscribe(response => {
        log.debug("Mobile login",response)
        this._authService.loadUser(this.queryParams?.redirect).subscribe()
      })
    }
  }

  resendOtp(){
    this.isOtpSent = false
    if(this.code?.length >= 2 && this.mobile?.length >= 9 && this.mobile?.length <= 10){
      this._authService.resendOtp(this.code,this.mobile).subscribe(response => {
        log.debug("Mobile otp",response)
        this.isOtpSent = true
      })
    }
  }


  onKey(event:any, item:string){
    if(item == 'mobile'){
      this.mobile = event.target.value;
      this.resendOtp()
    }else if(item == 'otp'){
      this.otp = event.target.value;
    }
    this.isValid = this.mobile?.length >= 9 && this.mobile?.length <= 10 && this.otp?.length == 4;
  }
}
