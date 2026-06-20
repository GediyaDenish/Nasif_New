import { Component, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { IUser } from 'src/app/interfaces/IUser';
import { AuthService } from 'src/app/services/auth.service';
import { LoaderService } from 'src/app/services/loader.service';
import { ProfileComponent } from '../profile/profile.component';

@Component({
  selector: 'app-nav-bar',
  templateUrl: './nav-bar.component.html',
  styleUrls: ['./nav-bar.component.scss']
})
export class NavBarComponent implements OnInit, OnDestroy {

  isLoading:boolean = false;
  loggedUser?:IUser;
  isSideNavOpen:boolean = true;
  private _unsubscribe: Subject<any> = new Subject();

  constructor(
    private _authService: AuthService,
    private _loaderService: LoaderService,
    public _dialog: MatDialog,
  ) { }

  ngOnInit(): void {
    this._loaderService.isLoading.pipe(takeUntil(this._unsubscribe)).subscribe(isLoading => {
      this.isLoading = isLoading;
    })

    this._authService.user.subscribe(user=>{
      this.loggedUser = user
      console.log(user)
    })
  }

  ngOnDestroy(): void {
    this._unsubscribe.next();
    this._unsubscribe.complete();
  }

  sideBar(){
    this.isSideNavOpen = !this.isSideNavOpen;
    this._authService.sideBarOpen.next(this.isSideNavOpen);
  }

  signOut(){
    this._authService.logout()
  }

  editProfile(){
    const dialogRef = this._dialog.open(ProfileComponent);
      dialogRef.afterClosed()
  }
}
