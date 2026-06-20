import { NgModule } from '@angular/core';
import { AppSharedModule } from 'src/app/app.shared.module';
import { RouterModule, Routes } from '@angular/router';
import { DashboardComponent } from './dashboard/dashboard.component';
import { AuthGuard } from 'src/app/guards/auth.guard';
import { UsersComponent } from './users/users.component';

const routes: Routes = [
  { path: 'dashboard', component: DashboardComponent , canActivate:[AuthGuard]},
  { path: 'users', component: UsersComponent , canActivate:[AuthGuard]},
  { path: 'configurations', canActivate:[AuthGuard], loadChildren: () => import(`./configuration/configuration.module`).then(module => module.ConfigurationModule) },
  { path: '**', redirectTo: 'dashboard', pathMatch: 'full' }
];

@NgModule({
  declarations: [
    DashboardComponent,
    UsersComponent
  ],
  imports: [
    AppSharedModule,
    RouterModule.forChild(routes)
  ]
})

export class AdminModule { }
