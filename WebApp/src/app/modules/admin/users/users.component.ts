import { Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { MatPaginator } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { finalize } from 'rxjs/operators';
import { IPage } from 'src/app/interfaces/IPage';
import { IPageable } from 'src/app/interfaces/IPageable';
import { IUser } from 'src/app/interfaces/IUser';
import { AuthService } from 'src/app/services/auth.service';
import { LoaderService } from 'src/app/services/loader.service';
import { Logger } from 'src/app/services/logger.service';
import { UserService } from 'src/app/services/user.service';

const log = new Logger('UserComponent');

@Component({
  selector: 'app-users',
  templateUrl: './users.component.html',
  styleUrls: ['./users.component.scss']
})

export class UsersComponent implements OnInit, OnDestroy {
  @ViewChild(MatPaginator) paginator!: MatPaginator;  
  search:string = "";
  loggedUser?:IUser;
  pageable: IPageable = {page: 0,size: 20,sort: 'displayName',search:""} as IPageable;
  pageSizeOptions: number[] = [10, 20, 50, 100];
  displayedColumns: string[] = ['name','mobile', 'blocked'];
  page?: IPage<IUser>;
  list: MatTableDataSource<IUser> = new MatTableDataSource();

  constructor(
    private _userService: UserService,
    private _authService: AuthService
  ) { }
  

  ngOnInit(): void {
    log.debug("ngOnInit")
    this._authService.user.subscribe(user => {
      this.loggedUser = user
    })
    this.getUsers()
  }

  ngOnDestroy(): void {
    
  }

  getUsers(){
    this._userService.getUsers(this.pageable).subscribe(dataPage => {
      this.page = dataPage;
      if(this.page?.content){
        this.list.data = this.page?.content;
      }else{
        this.list.data = [];
      }
    })
  }

  onSort(event:any){

  }

  onPageChange(event:any){
    this.pageable.page = event.pageIndex;
    this.pageable.size = event.pageSize;
    this.getUsers();
  }

  isAdmin(roles:string){
    return roles.includes('admin');
  }

  userBlock(event:any,user:IUser){
    this._userService.updateUser(user.id,event.checked,undefined).subscribe(() => {
      this.getUsers();
    })

  }

  userAdmin(event:any,user:IUser){
    this._userService.updateUser(user.id,undefined,event.checked).subscribe(() => {
      this.getUsers();
    })
  }

  filterData(event:any){
    if(event.keyCode == 13 || this.pageable.search == ''){
      this.pageable.page = 0;
      this.paginator.pageIndex = 0;
      this.getUsers();
    }
  }
}
