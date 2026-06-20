import { Component, Inject, OnInit } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';

@Component({
  selector: 'app-confirmation-dialog',
  templateUrl: './confirmation-dialog.component.html',
  styleUrls: ['./confirmation-dialog.component.scss']
})
export class ConfirmationDialogComponent implements OnInit {

  message?:string;
  title?:string;
  buttonTitle?:string;

  constructor(
    private dialogRef: MatDialogRef<ConfirmationDialogComponent>,
    @Inject(MAT_DIALOG_DATA) private data: any
  ) { 
    this.title = data.title;
    this.message = data.message;
  }

  ngOnInit(): void {

  }

  confirm() {
    this.dialogRef.close(true);
  }

  close() {
      this.dialogRef.close();
  }

}
