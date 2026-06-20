import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { UsersComponent } from './users.component';
import { AppSharedModule } from 'src/app/app.shared.module';

const routes: Routes = [
  { path: '', component: UsersComponent }
];
@NgModule({
  imports: [
      AppSharedModule,
      RouterModule.forChild(routes)
  ],
  exports: [RouterModule],
  declarations: [UsersComponent ]
})
export class UsersModule { }
