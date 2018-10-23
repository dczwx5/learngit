/**
 * 字典型的数据存取类。
 */
class Dictionary<T> {
	private m_keys: any[] = [];
	private m_values: T[] = [];

	public setDatas(data:{m_keys:any[], m_values: T[]}){
		this.m_keys = data.m_keys;
		this.m_values = data.m_values;
	}

	public get length(): number {
		return this.m_keys.length;
	}
	/**
	 * 获取所有的子元素列表。
	 */
	public get values(): T[] {
		return this.m_values.concat();
	}

	/**
	 * 获取所有的子元素键名列表。
	 */
	public get keys(): any[] {
		return this.m_keys.concat();
	}

	/**
	 * 给指定的键名设置值。
	 * @param	key 键名。
	 * @param	value 值。
	 */
	public set(key: any, value: T): void {
		var index: number = this.indexOfKey(key);
		if (index >= 0) {
			this.m_values[index] = value;
		} else {
			this.m_keys.push(key);
			this.m_values.push(value);
		}
	}

	public keyOfValue(value: T):any{
		return this.m_keys[this.indexOfValue(value)];
	}

	/**
	 * 获取指定对象的键名索引。
	 * @param	key 键名对象。
	 * @return 键名索引。
	 */
	public indexOfKey(key: any): number {
		return this.m_keys.indexOf(key);
	}

	public indexOfValue(val:T){
		return this.m_values.indexOf(val);
	}

	/**
	 * 是否存在某
	 * @param key
	 * @returns {boolean}
	 */
	public exist(key: any): boolean {
		return this.m_keys.indexOf(key) >= 0;
	}

	/**
	 * 遍历集合
	 * @param func 遍历的回调方法，如果返回值为true则继续遍历，返回false则break遍历
	 * @param thisObj
	 */
	public every(func:(idx:number, value:T) => boolean, thisObj:any = null){
		let len = this.keys.length;
		for(let i:number = 0; i < len; i++){
			if(thisObj){
				if(!func.call(thisObj, i, this.values[i])){
					break;
				}
			}else {
				if(!func(i, this.values[i])){
					break;
				}
			}
		}
	}

	/**
	 * 返回指定键名的值。
	 * @param	key 键名对象。
	 * @return 指定键名的值。
	 */
	public get(key: any): T {
		var index: number = this.indexOfKey(key);
		if (index >= 0) {
			return this.m_values[index];
		}
		return null;
	}

	/**
	 * 移除指定键名的值。
	 * @param	key 键名对象。
	 * @return 是否成功移除。
	 */
	public remove(key: any): T {
		var index: number = this.indexOfKey(key);
		if (index >= 0) {
			this.m_keys.splice(index, 1);
			return this.m_values.splice(index, 1)[0];
		}
		return null;
	}

	/**
	 * 清除此对象的键名列表和键值列表。
	 */
	public clear() {
		this.m_keys.length = 0;
		this.m_values.length = 0;
	}


	private static pool:Array<Dictionary<any>>;

	public static create():Dictionary<any>{
		var dictionary:Dictionary<any>;
		if(Dictionary.pool && Dictionary.pool.length>0){
			dictionary=Dictionary.pool.pop();
		}
		else {
			dictionary=new Dictionary<any>();
		}
		return dictionary;
	}

	public static release(direction:Dictionary<any>){
		if(!Dictionary.pool){
			Dictionary.pool=[];
		}
		direction.clear();
		Dictionary.pool.push(direction);
	}

}

