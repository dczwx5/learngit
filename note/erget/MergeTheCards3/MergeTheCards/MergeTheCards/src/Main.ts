//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2014-present, Egret Technology.
//  All rights reserved.
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the Egret nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY EGRET AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL EGRET AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;LOSS OF USE, DATA,
//  OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//////////////////////////////////////////////////////////////////////////////////////

import GradientType = egret.GradientType;
class Main extends eui.UILayer {

    private ps:egret.Point[];

    protected async createChildren() {
        super.createChildren();

        // this.test();
        // return;

        egret.lifecycle.addLifecycleListener((context) => {
            // custom lifecycle plugin
        });

        egret.lifecycle.onPause = () => {
            egret.ticker.pause();
        };

        egret.lifecycle.onResume = () => {
            egret.ticker.resume();
        };

        //inject the custom material parser
        //注入自定义的素材解析器
        let assetAdapter = new AssetAdapter();
        egret.registerImplementation("eui.IAssetAdapter", assetAdapter);
        egret.registerImplementation("eui.IThemeAdapter", new ThemeAdapter());

        await app.init();
        new App.MVC().startup();
        return;

        // this.runGame().catch(e => {
        //     console.log(e);
        // })

        let ps = this.ps = [
            egret.Point.create(300, 300),
            egret.Point.create(600, 300),
            egret.Point.create(500, 400),
            egret.Point.create(600, 600),
            egret.Point.create(300, 600),
            egret.Point.create(400, 400)
        ];

        let parentSp = new egret.Sprite();
        this.addChild(parentSp);
        parentSp.rotation = -45;

        let sp = new egret.Sprite();
        sp.touchEnabled = true;
        parentSp.addChild(sp);
        let g = sp.graphics;
        g.beginFill(0);
        g.drawRect(0,0, 1000, 1000);
        g.endFill();

        g.beginFill(0xff0000);
        let p:egret.Point;
        for(let i = 0; i < ps.length; i++){
            p = ps[i];
            if(i == 0){
                g.moveTo(p.x, p.y);
            }else {
                g.lineTo(p.x, p.y);
            }
        }
        p = ps[0];
        g.lineTo(p.x, p.y);
        g.endFill();
        sp.addEventListener(egret.TouchEvent.TOUCH_TAP, this.onTap, this);
        sp.rotation = 45;

    }

    private onTap(e:egret.TouchEvent){
        let p = egret.Point.create(e.localX, e.localY);
        let sp = e.currentTarget as egret.Sprite;
        console.log(sp.matrix.transformPoint(e.localX, e.localY));
        console.log(e.localX, e.localY);
        console.log(e.stageX, e.stageY);

        let ts = egret.getTimer();
        let b:boolean;
        for(let j = 0; j < 100; j++) {
            for (let i = 0; i < 6; i++) {
                b = VL.Geom.isPolygonContainsPoint(this.ps, p);
            }
        }
        ts = egret.getTimer() - ts;
        console.log(`isContain: ${b}`);
        console.log(`ts:${ts}`);

    }


    // private catchCount:number = 0;
    // async test(){
    //     await this.test1();
    //     await this.f3();
    // }
    // async test1(){
    //     await this.f1();
    //     await this.f2().catch(async ()=>{
    //         egret.log('catch f2 reject');
    //         if(this.catchCount++ < 3) {
    //             await this.test1();
    //         }else{
    //             egret.log('f2 fail Times Out');
    //         }
    //     });
    // }
    //
    // async f1(){
    //     return new Promise((resolve, reject) => {
    //         egret.log('f1 resolve');
    //         resolve();
    //     })
    // }
    // async f2(){
    //     return new Promise((resolve, reject) => {
    //         reject('f2 reject');
    //     })
    // }
    // async f3(){
    //     return new Promise((resolve, reject) => {
    //         egret.log('f3 resolve');
    //         resolve();
    //     })
    // }

}
