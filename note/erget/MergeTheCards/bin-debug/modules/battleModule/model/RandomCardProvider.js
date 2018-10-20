var RandomCardProvider = (function () {
    function RandomCardProvider() {
    }
    Object.defineProperty(RandomCardProvider.prototype, "cardPool", {
        get: function () {
            if (!this._cardPool) {
                var cfgs = app.config.getConfig(CardConfig);
                var cfg = void 0;
                var lv = this.currLv;
                var cardPool = this._cardPool = [];
                var weight = 0;
                for (var key in cfgs) {
                    cfg = cfgs[key];
                    // if (lv >= cfg.unlock) {//TODO: 配置文件将特殊牌权值改为0后用这行代码
                    if (lv >= cfg.unlock && cfg.type == Enum_CardType.NORMAL) {
                        weight += cfg.weight;
                        cardPool.push({ lessThan: weight, cfg: cfg });
                    }
                }
                Utils.ArrayUtils.quickSort(cardPool, function (a, b) {
                    return a.lessThan - b.lessThan;
                });
            }
            return this._cardPool;
        },
        enumerable: true,
        configurable: true
    });
    RandomCardProvider.prototype.getRandomCard = function (playerLv) {
        var cfgs = app.config.getConfig(CardConfig);
        var cfg;
        var lv = playerLv;
        var cardPool = [];
        var weight = 0;
        for (var key in cfgs) {
            cfg = cfgs[key];
            // if (lv >= cfg.unlock) {//TODO: 配置文件将特殊牌权值改为0后用这行代码
            if (lv >= cfg.unlock && cfg.type == Enum_CardType.NORMAL) {
                weight += cfg.weight;
                cardPool.push({ lessThan: weight, cfg: cfg });
            }
        }
        Utils.ArrayUtils.quickSort(cardPool, function (a, b) {
            return a.lessThan - b.lessThan;
        });
        var random = Math.random() * weight;
        for (var i = 0, l = cardPool.length; i < l; i++) {
            if (random <= cardPool[i].lessThan) {
                return cardPool[i].cfg;
            }
        }
        return null;
    };
    return RandomCardProvider;
}());
