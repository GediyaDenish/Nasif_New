import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-landing',
  templateUrl: './landing.component.html',
  styleUrls: ['./landing.component.scss']
})
export class LandingComponent implements OnInit {

  email?:string;
  isValid:boolean = false;
  emailPattern = RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);

  constructor() { }

  ngOnInit(): void {

  }

  onKey(event:any, item:string){
    if(item == 'email'){
      this.email = event.target.value;
      this.isValid = this.emailPattern.test(this.email ? this.email : "");
      console.log("IsValid",this.isValid)
    }
  }
  
  subscribeNewsLetter(){
    alert("Subscribe successfully");
  }
}
