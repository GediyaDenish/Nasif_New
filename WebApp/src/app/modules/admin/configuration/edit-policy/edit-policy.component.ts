import { Component, OnDestroy, OnInit } from '@angular/core';
import { ConfigService } from 'src/app/services/config.service';

@Component({
  selector: 'app-edit-policy',
  templateUrl: './edit-policy.component.html',
  styleUrls: ['./edit-policy.component.scss']
})
export class EditPolicyComponent implements OnInit, OnDestroy {

  htmlContent = '';
  
  constructor(
    private _configService:ConfigService
  ) { }

  ngOnInit(): void {
    this.getPolicy();
  }

  ngOnDestroy(): void {
    
  }

  getPolicy(){
    this._configService.getPolicy().subscribe((data) => {
      this.htmlContent = data.display;
    })
  }

  updatePolicy(){
    this._configService.updatePolicy(this.htmlContent).subscribe(() => {
      this.getPolicy()
    })
  }

}
