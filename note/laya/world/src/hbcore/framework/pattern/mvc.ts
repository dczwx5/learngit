export module mvc {
    // 未完成
    export class CMVC {
        private m_controller:CController;
        constructor(m:CModel, v:CView, c:CController) {
            this.m_controller = c;
            c.setView(v);
            c.setModel(m);
        }
    }
    export class CController {
        private m_view:CView;
        private m_model:CModel;
        
        setView(v:CView) {
            this.m_view = v;
        }
        setModel(v:CModel) {
            this.m_model = v;
        }

        update() {
            if (this.m_model.isDirty) {
                // this.onUpdateView();
                this.m_model.validate();
            }
        }
    }
    export class CView {
        // 只提代各种 get 
    }
    export class CModel extends Laya.EventDispatcher {
        get isDirty() : boolean {
            return this.m_bDirty;  
        }
        invalidate() {
            this.m_bDirty = true;
        }
        validate() {
            this.m_bDirty = false;
        }
    
        private m_bDirty:boolean;
    }
}