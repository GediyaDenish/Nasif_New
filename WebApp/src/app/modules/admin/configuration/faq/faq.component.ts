import { Component, OnDestroy, OnInit, TemplateRef, ViewChild } from '@angular/core';
import { MatDialog, MatDialogConfig } from '@angular/material/dialog';
import { MatTableDataSource } from '@angular/material/table';
import { ConfirmationDialogComponent } from 'src/app/components/confirmation-dialog/confirmation-dialog.component';
import { IFaq } from 'src/app/interfaces/IFaq';
import { IPage } from 'src/app/interfaces/IPage';
import { IPageable } from 'src/app/interfaces/IPageable';
import { FaqService } from 'src/app/services/faq.service';
import { Logger } from 'src/app/services/logger.service';

const log = new Logger('FaqComponent');

@Component({
  selector: 'app-faq',
  templateUrl: './faq.component.html',
  styleUrls: ['./faq.component.scss']
})
export class FaqComponent implements OnInit, OnDestroy {
  @ViewChild('createDialog') createDialog!: TemplateRef<any>;
  search:string = "";
  pageable: IPageable = {page: 0,size: 20,sort: 'createsAt',search:""} as IPageable;
  pageSizeOptions: number[] = [10, 20, 50, 100];
  displayedColumns: string[] = ['name','action'];
  page?: IPage<IFaq>;
  list: MatTableDataSource<IFaq> = new MatTableDataSource();
  selectedFaq?:IFaq;
  selectedQue:string = "";
  selectedAns:string = "";

  constructor(
    private _faqService: FaqService,
    public _dialog: MatDialog
  ) { }

  ngOnInit(): void {
    this.getFaqs();
  }

  ngOnDestroy(): void {
    
  }

  getFaqs(){
    this._faqService.getFaqs(this.pageable).subscribe(page => {
      this.page = page;
      this.list.data = this.page?.content;
    })
  }

  onPageChange(event:any){
    this.pageable.page = event.pageIndex;
    this.pageable.size = event.pageSize;
    this.getFaqs();
  }

  filterData(event:any){
    if(event.keyCode == 13 || this.pageable.search == ''){
      this.getFaqs();
    }
  }

  onCreate(){
    this.selectedFaq = undefined;
    this.selectedQue = "";
    this.selectedAns = "";
    const dialogConfig = new MatDialogConfig();  
    dialogConfig.width = "50vw";
    dialogConfig.maxWidth= "50vw";
    const dialogRef = this._dialog.open(this.createDialog,dialogConfig);
    dialogRef.afterClosed().subscribe(result => {
      if(result && this.selectedQue && this.selectedQue != "" && this.selectedAns && this.selectedAns != ""){
        this._faqService.createFaq(this.selectedQue, this.selectedAns).subscribe(data => {
          this.selectedFaq = undefined;
          this.selectedQue = "";
          this.selectedAns = "";
          this.getFaqs();
        })
      }
    });
  }

  onEdit(item:IFaq){
    this.selectedFaq = item;
    this.selectedQue = item.que;
    this.selectedAns = item.ans;
    const dialogConfig = new MatDialogConfig();  
    dialogConfig.width = "50vw";
    dialogConfig.maxWidth= "50vw";
    const dialogRef = this._dialog.open(this.createDialog,dialogConfig);
    dialogRef.afterClosed().subscribe(result => {
      if(result && this.selectedFaq && this.selectedQue && this.selectedQue != "" && this.selectedAns && this.selectedAns != ""){
        this._faqService.updateFaq(this.selectedFaq.id, this.selectedQue, this.selectedAns).subscribe(data => {
          this.selectedFaq = undefined;
          this.selectedQue = "";
          this.selectedAns = "";
          this.getFaqs();
        });
      }
    });
  }

  onDelete(item:IFaq){
    this.selectedFaq = item;
    const dialogConfig = new MatDialogConfig();  
    dialogConfig.data = {
        title: 'Delete',
        message: `Are you sure you want to delete?`
    };
    const dialogRef = this._dialog.open(ConfirmationDialogComponent, dialogConfig);

    dialogRef.afterClosed().subscribe(result => {
      if(result && this.selectedFaq){
        this._faqService.deleteFaq(this.selectedFaq.id).subscribe(data => {
          this.selectedFaq = undefined;
          this.selectedQue = "";
          this.selectedAns = "";
          this.getFaqs();
        });        
      }
    });
  }
}
