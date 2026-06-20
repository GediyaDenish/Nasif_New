import { Component, OnInit } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { IUser } from 'src/app/interfaces/IUser';
import { AuthService } from 'src/app/services/auth.service';
import { UserService } from 'src/app/services/user.service';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss']
})
export class ProfileComponent implements OnInit {
  private emailPattern = RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
  loggedUser?:IUser;
  mobile?:string;
  // email?:string;
  displayName?:string;
  isValid:boolean = false;
  
  constructor(
    private _authService: AuthService,
    private dialogRef: MatDialogRef<ProfileComponent>,
    private _userService: UserService
  ) { }

  ngOnInit(): void {
    this._authService.user.subscribe(user=>{
      this.loggedUser = user
      this.displayName = user?.displayName
      // this.email = user?.email
      this.mobile = user?.mobile
      this.checkValid()
    })
  }

  confirm() {
    this._userService.editProfile(this.displayName!,`${this.mobile!}`).subscribe(data => {
      this._authService.loadUser().subscribe(data => {
        this.dialogRef.close();
      })
    })
  }

  close() {
      this.dialogRef.close();
  }

  onKey(event:any){
    this.checkValid()
  }

  checkValid(){
    this.isValid = this.mobile != undefined
      && (`${this.mobile}`.length == 9 || `${this.mobile}`.length == 10)
  }
}
