import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AuthGuard } from './guards/auth.guard';
import { LandingComponent } from './modules/landing/landing.component';
import { PrivacyPolicyComponent } from './modules/privacy-policy/privacy-policy.component';
import { TermsOfUseComponent } from './modules/terms-of-use/terms-of-use.component';

const routes: Routes = [
  { path: 'auth', loadChildren: () => import(`./modules/auth/auth.module`).then(module => module.AuthModule) },
  { path: 'landing', component: LandingComponent },
  { path: 'privacy', component: PrivacyPolicyComponent },
  { path: 'terms', component: TermsOfUseComponent },
  { path: 'admin', canActivate:[AuthGuard], loadChildren: () => import(`./modules/admin/admin.module`).then(module => module.AdminModule) },
  { path: '**', redirectTo: 'admin', pathMatch: 'full' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
  providers: []
})
export class AppRoutingModule { }