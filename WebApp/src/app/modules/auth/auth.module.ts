import { NgModule } from "@angular/core";
import { RouterModule, Routes } from "@angular/router";
import { AppSharedModule } from "src/app/app.shared.module";
import { AuthComponent } from "./auth.component";

const routes: Routes = [
    { path: '', component: AuthComponent },
    { path: ':view', component: AuthComponent },
    { path: ':view/:type', component: AuthComponent },
];
@NgModule({
    imports: [
        AppSharedModule,
        RouterModule.forChild(routes)
    ],
    exports: [RouterModule],
    declarations: [AuthComponent ]
})

export class AuthModule { }