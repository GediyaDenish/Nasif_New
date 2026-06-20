import { CUSTOM_ELEMENTS_SCHEMA, NgModule } from '@angular/core';
import { MomentPipe } from './pipes/moment.pipe';
import { SignInWithEmailComponent } from './components/sign-in-with-email/sign-in-with-email.component';
import { SideBarComponent } from './components/side-bar/side-bar.component';
import { NavBarComponent } from './components/nav-bar/nav-bar.component';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ColorPickerModule } from 'ngx-color-picker';
import { AngularEditorModule } from '@kolkov/angular-editor';
import { NgxMatSelectSearchModule } from 'ngx-mat-select-search';

import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatCardModule } from '@angular/material/card';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatMenuModule } from '@angular/material/menu';
import { MatDialogModule } from '@angular/material/dialog';
import { MatTabsModule } from '@angular/material/tabs';
import { MatSelectModule } from "@angular/material/select";

import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ConfirmationDialogComponent } from './components/confirmation-dialog/confirmation-dialog.component';
import { SelectUserComponent } from './components/select-user/select-user.component';
import { ProfileComponent } from './components/profile/profile.component';
import { NgApexchartsModule } from 'ng-apexcharts';

const MODULES = [
  CommonModule,
  RouterModule,
  FormsModule,
  ReactiveFormsModule,
  ColorPickerModule,
  AngularEditorModule,
  NgxMatSelectSearchModule,
  NgApexchartsModule,

  MatSidenavModule,
  MatToolbarModule,
  MatIconModule,
  MatFormFieldModule,
  MatInputModule,
  MatCardModule,
  MatPaginatorModule,
  MatTableModule,
  MatButtonModule,
  MatSlideToggleModule,
  MatProgressBarModule,
  MatDialogModule,
  MatMenuModule,
  MatTabsModule,
  MatSelectModule
]
const COMPONENTS = [
  SignInWithEmailComponent,
  ConfirmationDialogComponent,
  SelectUserComponent,
  ProfileComponent,

  NavBarComponent,
  SideBarComponent
]
const PIPES = [
  MomentPipe
]

@NgModule({
  declarations: [
    ...COMPONENTS, ...PIPES
  ],
  imports: [...MODULES],
  exports: [...MODULES, ...COMPONENTS, ...PIPES],
  providers: [
      ...PIPES
  ],
  schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class AppSharedModule { }