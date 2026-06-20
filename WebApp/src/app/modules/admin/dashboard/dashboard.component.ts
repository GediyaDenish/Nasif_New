import { Component, OnInit } from '@angular/core';
import { Logger } from 'src/app/services/logger.service';
import { ApexOptions } from 'ng-apexcharts';
import { Router } from '@angular/router';
import { UserService } from 'src/app/services/user.service';
import { DealService } from 'src/app/services/deal.service';
import { PropertyService } from 'src/app/services/proeperty.service';
import { ChatService } from 'src/app/services/chat.service';

const log = new Logger('DashboardComponent');

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit {
  chartUserSummary: ApexOptions = {};
  chartDealSummary: ApexOptions = {};
  chartPropertySummary: ApexOptions = {};
  chartMessageSummary: ApexOptions = {};
  totalUser:number = 0;
  totalNewUser:number = 0;
  totalNewListing:number = 0;
  totalNewDeal:number = 0;
  totalMessages:number = 0;
  
  constructor(
    private _router: Router,
    private _userService: UserService,
    private _dealService: DealService,
    private _propertyService: PropertyService,
    private _chatService: ChatService
  ) { }

  ngOnInit(): void {
    log.debug("ngOnInit")
    this.getUserCounts(100 * 365);
    this.getUserCounts(6);
    this.getDealCounts(6);
    this.getPropertyCounts(6);
    this.getMessageCounts(6);
    this.getUserSummary(6);
    this.getMessageSummary(6);
    this.getDealSummary(6);
    this.getPropertySummary(6);
  }

  getUserCounts(days:number){
    this._userService.getCounts(days).subscribe(data => {
      if(data.status == `In last ${100 * 365} days`){
        this.totalUser = data.total;
      }else if(data.status == `In last ${days} days`){
        this.totalNewUser = data.total;
      }
    })
  }

  getDealCounts(days:number){
    this._dealService.getCounts(days).subscribe(data => {
      if(data.status == `In last ${days} days`){
        this.totalNewDeal = data.total;
      }
    })
  }

  getPropertyCounts(days:number){
    this._propertyService.getCounts(days).subscribe(data => {
      if(data.status == `In last ${days} days`){
        this.totalNewListing = data.total;
      }
    })
  }

  getMessageCounts(days:number){
    this._chatService.getMessagesCount(days).subscribe(data => {
      if(data.status == `In last ${days} days`){
        this.totalMessages = data.total;
      }
    })
  }

  getUserSummary(days:number){
    this._userService.getSummary(days).subscribe(data => {
      const users = data.chart.map((entry: { user: any; }) => entry.user);
      const times = data.chart.map(
        (entry: { time: string | number | Date }) =>
          new Date(entry.time).toLocaleDateString('en-IN', {
            day: '2-digit',
            month: 'short'
          }).replace(',', '') // '03 Nov'
            .replace(' ', '-') // '03-Nov'
      );

      this.chartUserSummary = {
        chart: {
          height: 350,
          type: "line",
          zoom: {
            enabled: false
          }
        },
        colors     : ['#EF4444FF', '#EF444480'],
        dataLabels : {
            enabled        : true,
            enabledOnSeries: [0],
            background     : {
                borderWidth: 0
            }
        },
        labels     : times,
        legend     : {
            show: false
        },
        plotOptions: {
            bar: {
                columnWidth: '50%'
            }
        },
        series     : [{
          name: 'Users',
          data: users
        }],
        states     : {
            hover: {
                filter: {
                    type : 'darken',
                    value: 0.75
                }
            }
        },
        stroke     : {
            width: [3, 0]
        },
        tooltip    : {
            followCursor: true,
            theme       : 'dark'
        },
        xaxis      : {
            axisBorder: {
                show: false
            },
            tooltip   : {
                enabled: false
            }
        },
        yaxis      : {
            labels: {
                offsetX: -16
            }
        }
      };
    });
  }

  getMessageSummary(days:number){
    this._chatService.getSummary(days).subscribe(data => {
      const messages = data.chart.map((entry: { messages: any; }) => entry.messages);
      const times = data.chart.map(
        (entry: { time: string | number | Date }) =>
          new Date(entry.time).toLocaleDateString('en-IN', {
            day: '2-digit',
            month: 'short'
          }).replace(',', '') // '03 Nov'
            .replace(' ', '-') // '03-Nov'
      );

      this.chartMessageSummary = {
        chart: {
          height: 350,
          type: "line",
          zoom: {
            enabled: false
          }
        },
        colors     : ['#22C55EFF', '#22C55E80'],
        dataLabels : {
            enabled        : true,
            enabledOnSeries: [0],
            background     : {
                borderWidth: 0
            }
        },
        labels     : times,
        legend     : {
            show: false
        },
        plotOptions: {
            bar: {
                columnWidth: '50%'
            }
        },
        series     : [{
          name: 'Messages',
          data: messages
        }],
        states     : {
            hover: {
                filter: {
                    type : 'darken',
                    value: 0.75
                }
            }
        },
        stroke     : {
            width: [3, 0]
        },
        tooltip    : {
            followCursor: true,
            theme       : 'dark'
        },
        xaxis      : {
            axisBorder: {
                show: false
            },
            tooltip   : {
                enabled: false
            }
        },
        yaxis      : {
            labels: {
                offsetX: -16
            }
        }
      };
    });
  }

  getDealSummary(days:number){
    this._dealService.getSummary(days).subscribe(data => {
      const deals = data.chart.map((entry: { deals: any; }) => entry.deals);
      const times = data.chart.map(
        (entry: { time: string | number | Date }) =>
          new Date(entry.time).toLocaleDateString('en-IN', {
            day: '2-digit',
            month: 'short'
          }).replace(',', '') // '03 Nov'
            .replace(' ', '-') // '03-Nov'
      );

      this.chartDealSummary = {
        chart: {
          height: 350,
          type: "line",
          zoom: {
            enabled: false
          }
        },
        colors     : ['#F59E0BFF', '#F59E0B80'],
        dataLabels : {
            enabled        : true,
            enabledOnSeries: [0],
            background     : {
                borderWidth: 0
            }
        },
        labels     : times,
        legend     : {
            show: false
        },
        plotOptions: {
            bar: {
                columnWidth: '50%'
            }
        },
        series     : [{
          name: 'Deals',
          data: deals
        }],
        states     : {
            hover: {
                filter: {
                    type : 'darken',
                    value: 0.75
                }
            }
        },
        stroke     : {
            width: [3, 0]
        },
        tooltip    : {
            followCursor: true,
            theme       : 'dark'
        },
        xaxis      : {
            axisBorder: {
                show: false
            },
            tooltip   : {
                enabled: false
            }
        },
        yaxis      : {
            labels: {
                offsetX: -16
            }
        }
      };
    });
  }

  getPropertySummary(days:number){
    this._propertyService.getSummary(days).subscribe(data => {
      const properties = data.chart.map((entry: { property: any; }) => entry.property);
      const times = data.chart.map(
        (entry: { time: string | number | Date }) =>
          new Date(entry.time).toLocaleDateString('en-IN', {
            day: '2-digit',
            month: 'short'
          }).replace(',', '') // '03 Nov'
            .replace(' ', '-') // '03-Nov'
      );

      this.chartPropertySummary = {
        chart: {
          height: 350,
          type: "line",
          zoom: {
            enabled: false
          }
        },
        colors     : ['#6D6D6DFF', '#6D6D6D80'],
        dataLabels : {
            enabled        : true,
            enabledOnSeries: [0],
            background     : {
                borderWidth: 0
            }
        },
        labels     : times,
        legend     : {
            show: false
        },
        plotOptions: {
            bar: {
                columnWidth: '50%'
            }
        },
        series     : [{
          name: 'Listing',
          data: properties
        }],
        states     : {
            hover: {
                filter: {
                    type : 'darken',
                    value: 0.75
                }
            }
        },
        stroke     : {
            width: [3, 0]
        },
        tooltip    : {
            followCursor: true,
            theme       : 'dark'
        },
        xaxis      : {
            axisBorder: {
                show: false
            },
            tooltip   : {
                enabled: false
            }
        },
        yaxis      : {
            labels: {
                offsetX: -16
            }
        }
      };
    });
  }
}
