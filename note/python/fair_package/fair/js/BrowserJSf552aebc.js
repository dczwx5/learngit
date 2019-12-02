//先初始化环境
; (function initialize() {
    var btn = document.createElement("button");
    btn.style.display = "none";
    btn.className = "btn";
    document.body.appendChild(btn);
    new ClipboardJS('.btn');

    var tempObj = {};
    tempObj.CONFIG = {
        URL_WALLET_LIST: "bcbwallet://req_info=bcbinforeq&HB_JS.listWallets",
        URL_EXIT_PAGE: "bcbwallet://req_info=exitpage"
    };

    window.HB_JS = tempObj;
})();

MyJSFunc = {
    HB_JS_FUNC: function () {
    }
}

HB_JS_FUNC = MyJSFunc.HB_JS_FUNC;

MyJSFunc.HB_JS_FUNC.prototype.clipboardCopy = function (txt) {
    var copyBtn = document.getElementsByClassName("btn")[0];
    copyBtn.setAttribute("data-clipboard-text", txt);
    copyBtn.click();
};




//------------- 原生JS--begin-------------------------------------------------

// 初始化vConsole  release版本需要移除vConsole
window.HB_JS.initVConsole = function () {
    window.vConsole = new VConsole({
        defaultPlugins: ['system', 'network', 'element', 'storage'], // 可以在此设定要默认加载的面板
        maxLogNumber: 400,
        onReady: function () {
            console.log('vConsole is ready.');
        },
        onClearLog: function () {
            console.log('on clearLog');
        }
    });
}

//提示需要游戏需要绑定全局函数,getWalletList查询得到的结果通过listWallets接口返回
window.HB_JS.listWallets = function (param) {
    alert("请绑定全局接口：listWallets");
}

//获取用户钱包地址列表       一进入游戏页面马上请求获取钱包地址
window.HB_JS.getWalletList = function () {
    let url = window.HB_JS.CONFIG.URL_WALLET_LIST;
    window.HB_JS.sendHttpReq(url);
};

//调用支付接口         参数为后台返回的支付短链
window.HB_JS.bcbwalletBridge = function (shortURL) {
    var url = "bcbwallet://req_pay=" + shortURL;
    window.HB_JS.sendHttpReq(url);
}

//支付成功后app调用我们的方法
window.inform = function (data) {
    if (window && window.console) {
        window.console.log('inform1');
        window.console.log(data, 'pay app cb');
    } else if (console){
        console.log('inform2');
        console.log(data, 'pay app cb');
    }
    
    // let status = sessionStorage.getItem('status')
    // if (data) {
    //     window.flag = false;
    //     if (status == '提现') {
    //         router.push({
    //             path: '/game/account'
    //         })
    //         sessionStorage.setItem('status', '')
    //     }
    //     if (status == '买名字') {
    //         router.replace({
    //             path: '/share'
    //         })
    //         sessionStorage.setItem('status', '')
    //         sessionStorage.setItem('buyName', 'true')
    //     }
    //     if (status == '买key') {
    //         // window.location.href='http://www.baidu.com'
    //         Event.$emit('buyKeySuccess', '');
    //         router.push({
    //             path: '/game/account'
    //         });
    //         sessionStorage.setItem('status', '')
    //     }
    // } else {
    //     // localStorage.setItem('myName', '')
    //     sessionStorage.setItem('status', '')
    //     router.push({
    //         path: '/discovery'
    //     })
    // }
}

//判断设备
window.HB_JS.device = function () {
    var u = window.navigator.userAgent;
    var device = '';
    if (u.indexOf('Android') > -1 || u.indexOf('Linux') > -1) {
        //安卓手机
        device = 'Android';
    } else if (u.indexOf('iPhone') > -1) {
        //苹果手机
        device = 'iPhone'
    } else if (u.indexOf('Windows Phone') > -1) {
        //winphone手机
        device = 'WindowsPhone'
    }
    return device;
}

//发送请求
window.HB_JS.sendHttpReq = function (url) {
    let device = window.HB_JS.device();
    window.console.log(url);

    switch (device) {
        case 'Android':
            var iframe = document.createElement('iframe');
            iframe.style.width = '1px';
            iframe.style.height = '1px';
            iframe.style.display = 'none';
            iframe.src = url;
            document.body.appendChild(iframe);
            setTimeout(function () {
                iframe.remove();
            }, 100);
            break;
        case 'iPhone':
            if (window.webkit) {
                window.webkit.messageHandlers.BCBPay.postMessage(url);
            }
            break;
        default:
            //TODO:nothing
            break;
    }
}

// // 原生返回发现页
// window.HB_JS.exitGame = function () {
//     window.HB_JS.sendHttpReq(window.HB_JS.CONFIG.URL_EXIT_PAGE);
// }
    // 原生返回发现页
window.HB_JS.exitGame = function () {
    const url = `bcbwallet://req_info=exitpage`;
    const device = window.HB_JS.device();
    if (device == 'Android' || device == 'WindowsPhone') {
        const iframe = document.createElement('iframe');
        iframe.style.width = '1px';
        iframe.style.height = '1px';
        iframe.style.display = 'none';
        iframe.src = url;
        document.body.appendChild(iframe);
        setTimeout(function () {
            iframe.remove();
        }, 100)
    }
    if (device == 'iPhone') {
        window.webkit.messageHandlers.BCBPay.postMessage(url);
    }
}
//------------- 原生JS--end-------------------------------------------------