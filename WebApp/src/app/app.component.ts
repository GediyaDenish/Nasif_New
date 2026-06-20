import { Component, OnDestroy, OnInit } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { environment } from 'src/environments/environment';
import { IUser } from './interfaces/IUser';
import { AuthService } from './services/auth.service';
import { LoaderService } from './services/loader.service';
import { Logger } from './services/logger.service';
import { SocketService } from './services/socket.service';

const log = new Logger('AppComponent');

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit, OnDestroy {
  isSideNavOpen:boolean = true;
  loggedUser?:IUser;
  isLogedIn:boolean = false;
  private _unsubscribe: Subject<any> = new Subject();

  constructor(
    private _translateService: TranslateService,
    private _authService: AuthService,
    private _loaderService: LoaderService,
    private _socketService: SocketService
  ){
    // Add languages
    this._translateService.addLangs([environment.defaultLanguage]);
    this._translateService.setDefaultLang(environment.defaultLanguage);
    this._translateService.use(environment.defaultLanguage);
    
    if (environment.production) {
      Logger.enableProductionMode();
    }

    log.debug('App Init');
    
  }

  ngOnInit(): void {
    
    this._authService.user.pipe(takeUntil(this._unsubscribe)).subscribe( user => {
      if(user){
        this.loggedUser = user;
        this._loaderService.hideSplash()
        this._socketService.init()
      } else if(!sessionStorage.getItem('accessToken')){
        setTimeout(()=>{
          this._loaderService.hideSplash()
        },500)
      }

      if(user && sessionStorage.getItem("accessToken")){
        this.isLogedIn = true;
      }
    })

    

    this._authService.sideBarOpen.pipe(takeUntil(this._unsubscribe)).subscribe( open => {
      this.isSideNavOpen = open;
    })

    if(sessionStorage.getItem("accessToken")){
      this._authService.loadUser('/dashboard').pipe(takeUntil(this._unsubscribe)).subscribe();
    }
    
  }
  
  ngOnDestroy(): void {
    this._unsubscribe.next();
    this._unsubscribe.complete();
  }

}
