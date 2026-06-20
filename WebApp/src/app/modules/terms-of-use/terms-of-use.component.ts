import { Component, OnInit } from '@angular/core';
import { ConfigService } from 'src/app/services/config.service';

@Component({
  selector: 'app-terms-of-use',
  templateUrl: './terms-of-use.component.html',
  styleUrls: ['./terms-of-use.component.scss']
})
export class TermsOfUseComponent implements OnInit {

  data?:string;

  constructor(
    private _configService:ConfigService
  ) { }

  ngOnInit(): void {
    this.getTerms();
  }

  getTerms(){
    this._configService.getTerms().subscribe(terms => {
      this.data = terms.display;
    })
  }

}
