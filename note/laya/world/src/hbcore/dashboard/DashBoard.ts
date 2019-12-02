import DashPage from "./DashPage";
import Panel = Laya.Panel;
import Text = Laya.Text;
import Event = Laya.Event;
import Sprite = Laya.Sprite;
import DashPageLog from "./DashPageLog";
import { log } from "../framework/log";

export default class DashBoard extends Sprite {
    private static m_instance:DashBoard;
    static get instance() : DashBoard {
        if (null == DashBoard.m_instance) {
            DashBoard.m_instance = new DashBoard();
        }
        return DashBoard.m_instance;
    }

    private constructor() {
        super();
    }

    initialize(isLocal:boolean) {
        this.m_isLocal = isLocal;
        if (isLocal) {
            // create
            this.m_lastClickTime = 0;
            this.m_stillClickCount = 0;
            this.m_pageList = new Array<DashPage>();
            this.m_panel = new Panel();
            this.m_panel.vScrollBarSkin = 'comp/vscroll.png';
            Laya.stage.addChild(this);
            this.addChild(this.m_panel);
    
            this.m_refreshBtn = new Laya.Button();
            this.m_refreshBtn.size(60, 30);
            this.m_refreshBtn.skin = 'comp/button.png';
            this.m_refreshBtn.label = 'refresh';
            this.m_refreshBtn.labelColors = '#ff0000';
            this.m_refreshBtn.clickHandler = new Laya.Handler(this, this._onRefresh);
            this.addChild(this.m_refreshBtn);

            this.m_closeBtn = new Laya.Button();
            this.m_closeBtn.size(60, 30);
            this.m_closeBtn.skin = 'comp/button.png';
            this.m_closeBtn.label = 'close';
            this.m_closeBtn.labelColors = '#ff0000';
            this.m_closeBtn.clickHandler = new Laya.Handler(this, this._onClose);
            this.addChild(this.m_closeBtn);

            // event
            Laya.stage.on(Event.RESIZE, this, this._onStageResize);
            this.on(Event.CLICK, this, this._onClick);
            

            this.addPage(new DashPageLog(this));

            this.open = false;
            

            // loop
            Laya.timer.loop(2000, this, this._loop);
        }
    }
    private _loop() {
        let topest = Laya.stage.getChildAt(Laya.stage.numChildren-1);
        if (topest && topest != this) {
            Laya.stage.setChildIndex(this, Laya.stage.numChildren-1);
            log.log('set test panel to topest');
        }
    }

    addPage(page:DashPage) {
        if (!this.isValidate) {
            return ;
        }
        this.m_panel.addChild(page);
        this.m_pageList.push(page);
    }
    removePage(page:DashPage) {
        if (!this.isValidate) {
            return ;
        }
        this.m_panel.removeChild(page);
        let idx:number = this.m_pageList.indexOf(page);
        if (-1 != idx) {
            this.m_pageList.splice(idx, 1);
        }
    }

    private set open(v:boolean) {
        if (!this.isValidate) {
            return ;
        }

        this.m_isOpen = v;
        if (v) {
            this.m_panel.width = Laya.stage.width;
            this.m_panel.height = Laya.stage.height*0.5;
            
            this.m_panel.graphics.clear();
            this.m_panel.graphics.drawRect(0, 0, this.m_panel.width, this.m_panel.height, '#000000', '#ffffff');

            this.pos(0, 0);
            this.width = this.m_panel.width;
            this.height = this.m_panel.height;
            this.alpha = 1;

            this.m_closeBtn.visible = true;
            this.m_closeBtn.x = this.width - 100;
            this.m_refreshBtn.visible = true;
            this.m_refreshBtn.x = this.m_closeBtn.x - 80;
            
        } else {
            // 非open时缩小到最左下角
            this.m_panel.width = 50;
            this.m_panel.height = 50;
            this.m_panel.graphics.clear();
            this.m_panel.graphics.drawRect(0, 0, this.m_panel.width, this.m_panel.height, '#000000', '#ffffff');
            this.width = this.m_panel.width;
            this.height = this.m_panel.height;
            this.pos(Laya.stage.width - 50, Laya.stage.height - 50);
            this.alpha = 0.01;

            this.m_refreshBtn.visible = false;
            this.m_closeBtn.visible = false; 
        }

        for (let page of this.m_pageList) {
            if (page.visible) {
                page.updateSize();
            }
        }
        
        this._refreshPageList();
    }

    private _refreshPageList() {
        for (let page of this.m_pageList) {
            if (page && page.visible) {
                page.updateView();
            }
        }
        this.m_panel.refresh();
    }

    private _onRefresh() {
        if (!this.isValidate) {
            return ;
        }
        this._refreshPageList();

    }
    private _onClose() {
        if (!this.isValidate) {
            return ;
        }
        this.m_stillClickCount = 0;
        this.open = false;

    }
    private _onClick() {
        if (!this.isValidate) {
            return ;
        }

        let curTime:number = Laya.timer.currTimer;
        if (curTime - this.m_lastClickTime < 1000) {
            this.m_stillClickCount++;
        } else {
            this.m_stillClickCount = 0;
        }

        if (this.m_stillClickCount >= 5) {
            this.m_stillClickCount = 0;
            this.open = !this.m_isOpen;
        }

        this.m_lastClickTime = Laya.timer.currTimer;
    }
    private _onStageResize() {
        if (!this.isValidate) {
            return ;
        }
        
        this.open = this.m_isOpen;
        for (let page of this.m_pageList) {
            page.visible = this.m_isOpen;
            if (page.visible) {
                page.updateSize();
            }
        }
        // console.log('resize-----------');
    }

    get isValidate() : boolean {
        return this.m_isLocal;
    }
    
    private m_panel:Panel;
    private m_pageList:Array<DashPage>;
    private m_refreshBtn:Laya.Button;
    private m_closeBtn:Laya.Button;

    private m_isLocal:boolean;
    private m_isOpen:boolean;

    private m_lastClickTime:number;
    private m_stillClickCount:number;
}