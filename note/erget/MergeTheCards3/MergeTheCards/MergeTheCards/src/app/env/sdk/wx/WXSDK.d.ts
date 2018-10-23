declare namespace wx {
    /**
     * 登录
     * @param arg
     */
    export function login(arg: {
        /**
         * 登录成功
         * @param code 用户登录凭证（有效期五分钟）。开发者需要在开发者服务器后台调用 code2Session，使用 code 换取 openid 和 session_key 等信息
         */
        success: (res: { code: string, sdkLogin: string }) => void,
        fail?: () => void,
        complete?: () => void,
        /**
         * 单位：ms
         */
        timeout?: number,
    });

    /**
     * 显示右上角菜单里的转发按钮
     * @param obj
     */
    export function showShareMenu(obj:{
         withShareTicket?:boolean,	//是否使用带 shareTicket 的转发详情
         success?:()=>void, 	//	接口调用成功的回调函数
         fail?:()=>void,		//	接口调用失败的回调函数
         complete?:()=>void		//	接口调用结束的回调函数（调用成功、失败都会执行）
    });

    /**
     * 隐藏右上角菜单里的转发按钮
     * @param obj
     */
    export function hideShareMenu(obj:{
         success?:()=>void, 	//	接口调用成功的回调函数
         fail?:()=>void,		//	接口调用失败的回调函数
         complete?:()=>void		//	接口调用结束的回调函数（调用成功、失败都会执行）
    });

    /**
     * 主动拉起转发，进入选择通讯录界面。
     * @param obj
     title    string    转发标题，不传则默认使用当前小游戏的昵称。
     imageUrl    string    转发显示图片的链接，可以是网络图片路径或本地图片文件路径或相对代码包根目录的图片文件路径。显示图片长宽比是 5:4
     query    string    查询字符串，从这条转发消息进入后，可通过 wx.getLaunchInfoSync() 或 wx.onShow() 获取启动参数中的 query。必须是 key1=val1&key2=val2 的格式。
     */
    export function shareAppMessage(obj: { title?: string, imageUrl?: string, query?: string });

    /**
     * 监听监听用户点击右上角菜单的“转发”按钮时触发的事件
     * @param callback
     title    string    转发标题，不传则默认使用当前小游戏的昵称。
     imageUrl    string    转发显示图片的链接，可以是网络图片路径或本地图片文件路径或相对代码包根目录的图片文件路径。显示图片长宽比是 5:4
     query    string    查询字符串，必须是 key1=val1&key2=val2 的格式。从这条转发消息进入后，可通过 wx.getLaunchOptionSync() 或 wx.onShow() 获取启动参数中的 query。
     */
    export function onShareAppMessage(callback: (res?: { title: string, imageUrl: string, query: string }) => { title?: string, imageUrl?: string, query?: string });

    /**
     * 获取启动参数
     */
    export function getLaunchOptionsSync(): {
        scene: number	//场景值
        query: any	//启动参数
        isSticky: boolean	//当前小游戏是否被显示在聊天顶部
        shareTicket: string	//shareTicket
        referrerInfo: {      //当场景为由从另一个小程序或公众号或App打开时，返回此字段
            appId: string,	//来源小程序或公众号或App的 appId
            extraData: object	//来源小程序传过来的数据，scene=1037或1038时支持
        }
    }

    /**
     * 监听小游戏回到前台的事件
     * @param callback
     */
    export function onShow(callback: (res: OnShowArgs) => void);

    export type OnShowArgs = {
        scene: string,	//场景值
        query: any,	//查询参数
        shareTicket: string,	//shareTicket
        referrerInfo: {
            appId: string,	//来源小程序或公众号或App的 appId
            extraData: object	//来源小程序传过来的数据，scene=1037或1038时支持
        }	//当场景为由从另一个小程序或公众号或App打开时，返回此字段
    }

    /**
     * 监听小游戏隐藏到后台事件。锁屏、按 HOME 键退到桌面、显示在聊天顶部等操作会触发此事件。
     * @param callback
     */
    export function onHide(callback: () => void);


    /**
     * 打开同一公众号下关联的另一个小程序（注：必须是同一公众号下，而非同个 open 账号下）。要求在用户发生过至少一次 touch 事件后才能调用。
     * @param object
     */
    export function navigateToMiniProgram(object: {
        appId: string,		//是	要打开的小程序 appId
        path?: string,		//否	打开的页面路径，如果为空则打开首页
        extraData?: object,		//否	需要传递给目标小程序的数据，目标小程序可在 App.onLaunch，App.onShow 中获取到这份数据。
        envVersion?: 'release' | 'develop' | 'trial',	//否	要打开的小程序版本。仅在当前小程序为开发版或体验版时此参数有效。如果当前小程序是正式版，则打开的小程序必定是正式版。
        success?: () => void,		//否	 接口调用成功的回调函数
        fail?: () => void,		//否	接口调用失败的回调函数
        complete?: () => void		//否	接口调用结束的回调函数（调用成功、失败都会执行）
    });


    /**
     * 获取开放数据域对象
     */
    export function getOpenDataContext(): OpenDataContext;

    /**
     * 托管数据
     * 托管数据的限制
     每个openid所标识的微信用户在每个游戏上托管的数据不能超过128个key-value对。
     上报的key-value列表当中每一项的key+value长度都不能超过1K(1024)字节。
     上报的key-value列表当中每一个key长度都不能超过128字节。
     * @param obj
     KVDataList    Array.<KVData>    要修改的 KV 数据列表
     success    function        接口调用成功的回调函数
     fail    function            接口调用失败的回调函数
     complete    function        接口调用结束的回调函数（调用成功、失败都会执行）
     */
    export function setUserCloudStorage(obj: {
        KVDataList: KVData[],
        success?: () => void,
        fail?: () => void,
        complete?: () => void
    });


    export class OpenDataContext {
        /**
         * 开放数据域和主域共享的 sharedCanvas
         */
        // canvas:Canvas;

        /**
         *  向开放数据域发送消息
         * @param message 要发送的消息，message 中及嵌套对象中 key 的 value 只能是 primitive value。即 number、string、boolean、null、undefined。
         */
        postMessage(message: Object);
    }

    /**
     * 缓存
     * @param key
     * @param data
     */
    export function setStorageSync(key: string, data: Object | string);

    /**
     *
     * @param key
     */
    export function getStorageSync(key: string): Object | string;

    /**
     * 获取系统信息
     */
    export function getSystemInfoSync(): SystemInfo;

    export type SystemInfo = {
        // 属性	类型	 说明	支持版本
        brand: string;	//手机品牌	>= 1.5.0
        model: string;	// 手机型号
        pixelRatio: number;	//设备像素比
        screenWidth: number;//屏幕宽度	>= 1.1.0
        screenHeight: number;	//屏幕高度	>= 1.1.0
        windowWidth: number;	//可使用窗口宽度
        windowHeight: number;	//可使用窗口高度
        language: string;	//微信设置的语言
        version: string;	//微信版本号
        system: string;	//操作系统版本
        platform: string;	//客户端平台
        fontSizeSetting: number;	//用户字体大小设置。以“我-设置-通用-字体大小”中的设置为准，单位 px。	>= 1.5.0
        SDKVersion: string;	//客户端基础库版本	>= 1.1.0
        benchmarkLevel: number;	//性能等级，-2 或 0：该设备无法运行小游戏，-1：性能未知，>=1 设备性能值，该值越高，设备性能越好(目前设备最高不到50)	>= 1.8.0
        battery: number;	//电量，范围 1 - 100	>= 1.9.0
        wifiSignal: number;	//wifi 信号强度，范围 0 - 4	>= 1.9.0
    }

    export type KVData = {
        key: string;
        value: string;
    }

    export function getUpdateManager(): UpdateManager;

    export class UpdateManager {
        /**
         * 当小程序新版本下载完成后（即收到 onUpdateReady 回调），强制小程序重启并使用新版本
         */
        applyUpdate();

        /**
         * 监听向微信后台请求检查更新结果事件。微信在小程序冷启动时自动检查更新，不需由开发者主动触发。
         */
        onCheckForUpdate(callback: (res: { hasUpdate: boolean }) => void);

        /**
         * 监听小程序有版本更新事件。客户端主动触发下载（无需开发者触发），下载成功后回调
         * @param callback
         */
        onUpdateReady(callback: () => void);

        /**
         * 监听小程序更新失败事件。小程序有新版本，客户端主动触发下载（无需开发者触发），下载失败（可能是网络原因等）后回调
         * @param callback
         */
        onUpdateFailed(callback: () => void);
    }

    /**
     * 显示模态对话框
     * @param args
     属性    类型    默认值    是否必填    说明    支持版本
     title    string        是    提示的标题
     content    string        是    提示的内容
     showCancel    boolean    true    否    是否显示取消按钮
     cancelText    string    '取消'    否    取消按钮的文字，最多 4 个字符
     cancelColor    string    #000000    否    取消按钮的文字颜色，必须是 16 进制格式的颜色字符串
     confirmText    string    '确定'    否    确认按钮的文字，最多 4 个字符
     confirmColor    string    #3cc51f    否    确认按钮的文字颜色，必须是 16 进制格式的颜色字符串
     success    function        否    接口调用成功的回调函数
     fail    function        否    接口调用失败的回调函数
     complete    function        否    接口调用结束的回调函数（调用成功、失败都会执行）
     */
    export function showModal(args: {
        title: string,
        content: string,
        showCancel?: boolean,
        cancelText?: string,
        cancelColor?: string,
        confirmText?: string,
        confirmColor?: string,
        /**
         *
         * @param res
         confirm    boolean    为 true 时，表示用户点击了确定按钮
         cancel    boolean    为 true 时，表示用户点击了取消（用于 Android 系统区分点击蒙层关闭还是点击取消按钮关闭）
         */
        success?: (res: { confirm: boolean, cancel: boolean }) => void,
        fail?: () => void,
        complete?: () => void
    });

    /**
     * 创建激励视频广告组件。请通过 wx.getSystemInfoSync() 返回对象的 SDKVersion 判断基础库版本号 >= 2.0.4 后再使用该 API。同时，开发者工具上暂不支持调试该 API，请直接在真机上进行调试。
     * @param object
     * adUnitId 广告单元 id
     */
    export function createRewardedVideoAd(object: { adUnitId: string }): RewardedVideoAd

    /**
     * 激励视频广告组件。激励视频广告组件是一个原生组件，并且是一个全局单例。层级比上屏 Canvas 高，会覆盖在上屏 Canvas 上。激励视频 广告组件默认是隐藏的，需要调用 RewardedVideoAd.show() 将其显示。
     */
    export class RewardedVideoAd {
        /**
         * 广告单元 id
         */
        readonly adUnitId: string;

        /** 隐藏激励视频广告 */
        load(): Promise<void>;

        /** 显示激励视频广告。激励视频广告将从屏幕下方推入。 */
        show(): Promise<void>;

        /**
         * 监听激励视频广告加载事件
         * @param callback 要注册的监听方法
         */
        onLoad(callback: () => void);

        /**
         * 取消监听激励视频广告加载事件
         * @param callback 要注销的监听方法
         */
        offLoad(callback: () => void);

        /**
         * 监听激励视频错误事件
         * @param callback 要注册的监听方法
         * errMsg    string    错误信息
         * errCode    number    错误码    >= 2.2.2
         */
        onError(callback: (res: { errMsg: string, errCode: number }) => void);

        /**
         * 取消监听激励视频错误事件
         * @param callback 要注销的监听方法
         */
        offError(callback: (res: { errMsg: string, errCode: number }) => void);

        /**
         * 监听用户点击 关闭广告 按钮的事件
         * @param callback 要注册的监听方法
         * isEnded    boolean    视频是否是在用户完整观看的情况下被关闭的    >= 2.1.0
         */
        onClose(callback: (res: { isEnded: boolean }) => void);

        /**
         * 取消监听用户点击 关闭广告 按钮的事件
         * @param callback 要注销的监听方法
         */
        offClose(callback: (res: { isEnded: boolean }) => void);
    }

    export type WxAdError = {
        /**
         * 错误码
         */
        code: number;
        /**
         * 描述
         */
        desc: string;
        /**
         * 原因
         */
        reason: string;
        /**
         * 解决方案
         */
        solution: string;
    }
    export let WxAdErrorMap: { [errCode: number]: wx.WxAdError };

    /**
     * 创建 banner 广告组件。请通过 wx.getSystemInfoSync() 返回对象的 SDKVersion 判断基础库版本号 >= 2.0.4 后再使用该 API。同时，开发者工具上暂不支持调试该 API，请直接在真机上进行调试。
     */
    export function createBannerAd(
        obj:{
            adUnitId:string,
            style:BannerAdStyle
        }
    ):BannerAd;

    export class BannerAd {
        readonly style: {
            left: number,	//banner 广告组件的左上角横坐标
            top: number,     //banner 广告组件的左上角纵坐标
            width: number,   //	banner 广告组件的宽度。最小 300，最大至 屏幕宽度（屏幕宽度可以通过 wx.getSystemInfoSync() 获取）。
            height: number, //	banner 广告组件的高度
            realWidth: number,	//banner 广告组件经过缩放后真实的宽度
            realHeight: number	//banner 广告组件经过缩放后真实的高度
        };

        /**
         * 显示 banner 广告。
         */
        show(): Promise<void>;

        /**
         * 隐藏 banner 广告
         */
        hide();

        /**
         * 销毁 banner 广告
         */
        destroy();

        /**
         * 监听banner 广告尺寸变化事件
         * @param callback
         */
        onResize(callback: (res: { width: number, height: number }) => void);

        /**
         * 取消监听banner 广告尺寸变化事件
         * @param callback
         */
        offResize(callback: (res: { width: number, height: number }) => void);


        /**
         * 监听banner 广告加载事件
         * @param callback
         */
        onLoad(callback: () => void);


        /**
         * 取消监听banner 广告加载事件
         * @param callback
         */
        offLoad(callback: () => void);


        /**
         * 监听banner 广告错误事件
         * @param callback
         */
        onError(callback: (res: {
            errMsg: string,	//错误信息
            errCode: number	//错误码	>= 2.2.2
        }) => void);


        /**
         * 取消监听banner 广告错误事件
         * @param callback
         */
        offError(callback: (res: {
            errMsg: string,	//错误信息
            errCode: number	//错误码	>= 2.2.2
        }) => void);

    }

    /**
     * Banner广告的样式
     */
    export type BannerAdStyle = {
        left:number,		//banner 广告组件的左上角横坐标
        top:number,		//banner 广告组件的左上角纵坐标
        width:number,		//banner 广告组件的宽度
        height?:number		//banner 广告组件的高度
    }
}