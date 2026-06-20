import { Component, OnInit } from '@angular/core';
import { ConfigService } from 'src/app/services/config.service';

@Component({
  selector: 'app-privacy-policy',
  templateUrl: './privacy-policy.component.html',
  styleUrls: ['./privacy-policy.component.scss']
})
export class PrivacyPolicyComponent implements OnInit {

  data?:string;

  constructor(
    private _configService:ConfigService
  ) { }

  ngOnInit(): void {
    this.getPrivacy();
  }

  getPrivacy(){
    this._configService.getPolicy().subscribe(policy => {
      this.data = policy.display;
    })
  }
}
