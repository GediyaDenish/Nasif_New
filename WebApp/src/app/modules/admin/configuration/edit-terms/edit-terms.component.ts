import { Component, OnDestroy, OnInit } from '@angular/core';
import { ConfigService } from 'src/app/services/config.service';

@Component({
  selector: 'app-edit-terms',
  templateUrl: './edit-terms.component.html',
  styleUrls: ['./edit-terms.component.scss']
})
export class EditTermsComponent implements OnInit, OnDestroy {

  htmlContent = '';
  
  constructor(
    private _configService:ConfigService
  ) { }

  ngOnInit(): void {
    this.getTerms();
  }

  ngOnDestroy(): void {
    
  }

  getTerms(){
    this._configService.getTerms().subscribe((data) => {
      this.htmlContent = data.display;
    })
  }

  updateTerms(){
    this._configService.updateTerms(this.htmlContent).subscribe(() => {
      this.getTerms()
    })
  }
}