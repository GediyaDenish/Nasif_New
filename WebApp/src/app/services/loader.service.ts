import { Inject, Injectable } from '@angular/core';
import { DOCUMENT } from '@angular/common';
import { NavigationEnd, Router } from "@angular/router";
import { BehaviorSubject } from "rxjs";
import { Logger } from "./logger.service";
import { filter, take } from 'rxjs/operators';
import { animate, AnimationBuilder, AnimationPlayer, style } from '@angular/animations';

const log = new Logger('LoaderService');

@Injectable({
    providedIn: 'root'
})
export class LoaderService {
    private splashScreenEl: any;
    private player?: AnimationPlayer;

    private _isLoading:boolean = false;
    public isLoading: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(this._isLoading);

    constructor(
        private _animationBuilder: AnimationBuilder,
        @Inject(DOCUMENT) private _document: any,
        private _router: Router
    ){
        this.splashScreenEl = this._document.body.querySelector('#splash-screen');
        if ( this.splashScreenEl )
        {
            // Hide it on the first NavigationEnd event
            this._router.events
                .pipe(
                    filter((event => event instanceof NavigationEnd)),
                    take(1)
                )
                .subscribe(() => {
                    setTimeout(() => {
                        // this.hideSplash();
                    });
                });
        }
    }

    showLoader(){
        this.isLoading.next(true)
    }

    hideLoader(){
        this.isLoading.next(false)
    }

    showSplash(){
        this.player = this._animationBuilder
            .build([
                style({
                    opacity: '0',
                    zIndex : '99999'
                }),
                animate('400ms ease', style({opacity: '1'}))
            ]).create(this.splashScreenEl);
        setTimeout(() => {
            this.player?.play();
        }, 0);
    }

    hideSplash(){
        this.player = this._animationBuilder
            .build([
                style({opacity: '1'}),
                animate('400ms ease', style({
                    opacity: '0',
                    zIndex : '-10'
                }))
            ]).create(this.splashScreenEl);
        setTimeout(() => {
            this.player?.play();
        }, 0);
    }
}