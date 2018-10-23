if (window.hasOwnProperty('wx')) {
    wx.WxAdErrorMap = {
        0: { code: 0, desc: "观看视频次数用尽", reason: "观看视频次数用尽", solution: "次日恢复" },
        1000: { code: 1000, desc: "后端错误调用失败", reason: "该项错误不是开发者的异常情况", solution: "一般情况下忽略一段时间即可恢复。" },
        1001: { code: 1001, desc: "参数错误", reason: "使用方法错误", solution: "可以前往developers.weixin.qq.com确认具体教程（小程序和小游戏分别有各自的教程，可以在顶部选项中，“设计”一栏的右侧进行切换。" },
        1002: { code: 1002, desc: "广告单元无效", reason: "可能是拼写错误、或者误用了其他APP的广告ID", solution: "请重新前往mp.weixin.qq.com确认广告位ID。" },
        1003: { code: 1003, desc: "内部错误", reason: "该项错误不是开发者的异常情况", solution: "一般情况下忽略一段时间即可恢复。" },
        1004: { code: 1004, desc: "无适合的广告", reason: "广告不是每一次都会出现，这次没有出现可能是由于该用户不适合浏览广告", solution: "属于正常情况，且开发者需要针对这种情况做形态上的兼容。" },
        1005: { code: 1005, desc: "广告组件审核中", reason: "你的广告正在被审核，无法展现广告", solution: "请前往mp.weixin.qq.com确认审核状态，且开发者需要针对这种情况做形态上的兼容。" },
        1006: { code: 1006, desc: "广告组件被驳回", reason: "你的广告审核失败，无法展现广告", solution: "请前往mp.weixin.qq.com确认审核状态，且开发者需要针对这种情况做形态上的兼容。" },
        1007: { code: 1007, desc: "广告组件被驳回", reason: "你的广告能力已经被封禁，封禁期间无法展现广告", solution: "请前往mp.weixin.qq.com确认小程序广告封禁状态。" },
        1008: { code: 1008, desc: "广告单元已关闭", reason: "该广告位的广告能力已经被关闭", solution: "请前往mp.weixin.qq.com重新打开对应广告位的展现。" }
    };
}
//# sourceMappingURL=WxAdErrorMap.js.map