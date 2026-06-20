import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AppSharedModule } from 'src/app/app.shared.module';
import { EditPolicyComponent } from './edit-policy/edit-policy.component';
import { EditTermsComponent } from './edit-terms/edit-terms.component';
import { FaqComponent } from './faq/faq.component';

const routes: Routes = [
  { path: 'policy', component: EditPolicyComponent },
  { path: 'terms', component: EditTermsComponent },
  { path: 'faq', component: FaqComponent },
  { path: '', redirectTo: 'faq', pathMatch: 'full' }
];

@NgModule({
  declarations: [
    EditPolicyComponent,
    EditTermsComponent,
    FaqComponent
  ],
  imports: [
    AppSharedModule,
    RouterModule.forChild(routes)
  ]
})
export class ConfigurationModule { }
