export module facade {
    // 未完成
    export class CFacade {
        constructor(pOwner:any) {
            this.m_owner = this.m_owner;
        }

        protected m_owner:any;
    }  
}

/** 例
class Item {
    id:number;
}
class BagSystem {
    facade:BagFacade; // 对外提供facade即, 外部不直接访问bagSystem
    itemList:Array<Item>; // 子系统
    constructor() {
        this.facade = new BagFacade(this);
    }
}

class BagFacade extends facade.CFacade {
    constructor(pOwner:BagSystem) {
        super(pOwner);
    }
    
    // 提供接口, 封装操作
    getItem(itemID:number) {
        const itemList = this.owner.itemList;
        for (let item of itemList) {
            if (item.id == itemID) {
                return item;
            }
        }
    }

    get owner() {
        return this.m_owner as BagSystem;
    }
}

// 使用
let bagSystem = new BagSystem();
bagSystem.facade.getItem(1);
*/