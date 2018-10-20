/**
 * Created by MuZi on 2018/9/10.
 */
var ShareVO = (function () {
    function ShareVO() {
    }
    ShareVO.prototype.setQuery = function (key, val) {
        if (this._query) {
            this._query = this._query + "&" + key + "=" + val;
        }
        else {
            this._query = key + "=" + val;
        }
    };
    Object.defineProperty(ShareVO.prototype, "query", {
        get: function () {
            return this._query;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ShareVO.prototype, "imgType", {
        set: function (value) {
            this._imgType = value;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ShareVO.prototype, "imgName", {
        set: function (value) {
            this._imgName = value;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ShareVO.prototype, "imgURL", {
        get: function () {
            var result;
            switch (this._imgType) {
                case E_SAHRE_IMG_TYPE.DIY:
                    result = this._imgName;
                    break;
                case E_SAHRE_IMG_TYPE.HEAD_ICON:
                    // result = UserResUtil.CDNHeadImgUrl(PlayerModel.UID, PlayerModel.head_image_version);
                    break;
                // case E_SAHRE_IMG_TYPE.GAME_ICON:
                //     result = AppConfig.RES_SERVER_CNF + 'assets/icon_200.png';
                //     break;
                default:
                    // result = AppConfig.gameIconUrl;
                    break;
            }
            return result;
        },
        enumerable: true,
        configurable: true
    });
    return ShareVO;
}());
