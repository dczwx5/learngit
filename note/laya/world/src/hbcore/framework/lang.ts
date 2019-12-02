
export default class Lang {

    static TEST_FIND_ERROR:boolean = false;
    
    static Get(key:string, params:Object = null) : string {
        if (Lang.TEST_FIND_ERROR) return key;
        if (!Lang._lang) return key;
    
        let value : string = Lang._lang[ key ];
        if (value && value.length > 0) {
            if (params) {
                for (let paramKey in params) {
                    let findKey:string = "{" + paramKey + "}";
                    if (value.indexOf(findKey) != -1) {
                        value = value.replace(findKey, params[paramKey]);
                    }
                }
            }
        } else {
            value = key;
        }
    
        return value;
    }
    
    private static _lang:Object;
    static hasKey(key:string) : boolean {
        return Lang._lang.hasOwnProperty(key);
    }
    
    static initialize(xml:XMLDocument ):void {
        if (!xml) return ;
        if (!Lang._lang) {
            Lang._lang = new Object();
  
            let childNodes = xml.childNodes[0].childNodes;
            let node;
            for (let i:number = 0; i < childNodes.length; ++i) {
                node = childNodes[i];node.id;node.textContent;
                Lang._lang[node.id] = node.textContent;
            }
        }
    }
    // static getStringCharLength( str : string ) : int {
    //     let bytes : ByteArray = new ByteArray();
    //     bytes.writeMultiByte( str, "gb2312" );
    //     bytes.position = 0;
    //     return bytes.length;
    // }
    
    // static getCommonNumber(value:number) : string {
    //     if (value <= 10) {
    //         return Lang.Get("common_number_china_" + value);
    //     } else {
    //         return value.toString();
    //     }
    // }
}
    